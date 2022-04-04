#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
#include <vector>
#include <memory>

#include <stream.hpp> 
#include <rate_controller.hpp>
#include <galois_field.hpp>
#include <decoder.hpp>
#include <encoder.hpp>
#include <symbol.hpp>
#include <socket.hpp>

using symbol_ptr = std::unique_ptr<std::vector<uint8_t>>;

int main()
{
    int printall = 0;
    uint64_t total_transmitted_packets = 2000000U;
    uint64_t max_window_size = 8U; 
    uint64_t current_window_size = max_window_size;
    uint64_t num_coded_symbols = 0; 
    uint64_t symbol_size = 1000U;     
    uint64_t seed = 0;
    std::vector<uint8_t> packet;
    uint64_t current_pkt_id = 0;
    uint64_t next_symbol_id = 0;
    uint64_t latest_symbol_id;
    packet.resize(symbol_size);
    stream<symbol_ptr> input_symbols;
    uint16_t num_source_symbols = 1;
    uint16_t num_total_symbols = 2;
    rate_controller rate{num_total_symbols, num_source_symbols};
    unsigned char packet_data[24 + symbol_size];
    uint64_t max_window_size_rcv = 16U;
    stream<symbol_ptr> output_symbols;
    stream<bool> decoded_symbols;
    uint64_t num_of_decoded_symbols = 0;
    std::vector<uint8_t> coefficients_rcv;
    stream<symbol_ptr> coefficients_stream;
    unsigned char packet_data_rcv[symbol_size];
    uint64_t latest_symbol_id_rcv;
    uint64_t num_coded_symbols_rcv = 0;
    uint64_t seed_rcv = 0;
    std::vector<uint8_t> packet_rcv;
    uint64_t total_recv_pkt = 0;
    uint64_t current_lower_bound = 0;

    while (current_pkt_id < total_transmitted_packets)
    {
        printf("current pkt id: %lu \n",current_pkt_id);   
        uint64_t seed = rand();
        srand(seed);     
        if (!rate.send_repair())
        {       
            if (input_symbols.size() == max_window_size)
            {
                input_symbols.pop_back();
            }
            printf("generate new symbol id: %lu, content:", next_symbol_id);
            auto symbol_pointer = generate_symbol(symbol_size);
            input_symbols.push_front(std::move(symbol_pointer));
            num_coded_symbols = 1;
            next_symbol_id++;
        }
        else
        {
            // coding window: (only when symbol is enough, this will be the same as max_window_size)
            num_coded_symbols = input_symbols.size();
        }
        latest_symbol_id = next_symbol_id - 1;
        seed = encode_pkt(&packet, &input_symbols, num_coded_symbols);
        ++current_pkt_id;
        rate.advance();
        build_payload(packet_data, &latest_symbol_id, &num_coded_symbols, &seed, &packet);

        if (rand() % 2)
        {
            if (printall)
            {
                printf("pkt loss \n");
            }

            continue;
        }
        // decoder part
        if (printall)
        {
            printf("pkt received \n");
        }
        total_recv_pkt++;
        latest_symbol_id_rcv = latest_symbol_id;
        num_coded_symbols_rcv = num_coded_symbols;
        seed_rcv = seed;
        packet_rcv = packet;
        if ((latest_symbol_id_rcv - num_coded_symbols + 1) < output_symbols.lower_bound())
        {
            continue;
        }
        if (output_symbols.upper_bound() <= latest_symbol_id_rcv)
        {
            while (output_symbols.size() < max_window_size_rcv)
            {
                auto symbol_pointer = generate_empty_symbol(symbol_size);
                output_symbols.push_front(std::move(symbol_pointer));
                decoded_symbols.push_front(false);
                auto coeff_pointer = generate_empty_symbol(max_window_size_rcv);
                coefficients_stream.push_front(std::move(coeff_pointer));
            }
        }

        while (output_symbols.upper_bound() <= latest_symbol_id_rcv)
        {
            if (coefficients_stream.at(coefficients_stream.lower_bound())->at(0) != 0)
            {
                auto symbol_pointer = std::move(output_symbols.back());
                output_symbols.pop_back();
                output_symbols.push_front(std::move(symbol_pointer));
                clear_last_symbol(&output_symbols);
                auto coeff_pointer = std::move(coefficients_stream.back());
                coefficients_stream.pop_back();
                coefficients_stream.push_front(std::move(coeff_pointer));
                clear_last_coeff(&coefficients_stream);
            }
            else
            {
                output_symbols.m_stream_offset++;
                coefficients_stream.m_stream_offset++;
            }

            for (uint64_t i = coefficients_stream.lower_bound(); i < coefficients_stream.upper_bound(); i++)
            {
                rotate(coefficients_stream.at(i)->begin(),(coefficients_stream.at(i)->begin()+1),coefficients_stream.at(i)->end());
            }
            decoded_symbols.pop_back();
            decoded_symbols.push_front(false);
        }
        handle_coefficient_rcv(&coefficients_rcv, &coefficients_stream, latest_symbol_id_rcv, num_coded_symbols_rcv, seed_rcv);
        handle_packet_rcv(&packet_rcv, &output_symbols);
        if(printall)
        {
            print_matrix(&output_symbols);
            print_matrix(&coefficients_stream);
        }
        stream_elimination(&coefficients_stream, &output_symbols);
        num_of_decoded_symbols += decode_pkt(&coefficients_stream, &output_symbols, &decoded_symbols);
    }
    return 0;
}
