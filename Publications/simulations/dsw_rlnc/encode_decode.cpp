#include <algorithm>
#include <iostream>
#include <memory>
#include <vector>
#include <decoder.hpp>
#include <encoder.hpp>
#include <rate_controller.hpp>
#include <stream.hpp>

// others
#include <link.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <netinet/ether.h>
#include <arpa/inet.h>
#include <linux/if_packet.h>
#include <fstream>
#include "json.hpp"
using namespace std;
using json = nlohmann::json;

using symbol_ptr = std::unique_ptr<std::vector<uint8_t>>;

symbol_ptr make_symbol(uint32_t size)
{
    symbol_ptr data = std::make_unique<std::vector<uint8_t>>();
    data->resize(size);
    return data;
}

void get_symbol_from_app(symbol_ptr *symbol_pointer, uint32_t size)
{
    static uint8_t num = 0;
    for (uint32_t i = 0; i < size; i++)
    {
        (*symbol_pointer)->at(i) = num;
    }
    num++;
}

symbol_ptr generate_symbol(uint32_t size)
{
    symbol_ptr data = make_symbol(size);
    get_symbol_from_app(&data, size);
    return data;
}

void print_array_uc(unsigned char *array, int num)
{
    int k = 0;
    for (int i = 0; i < num; i++)
    {
        k++;
        printf("%u ", array[i]);
        if (!(k % 10))
        {
            printf("\n");
        }
    }
}

#define DEFAULT_IF "enp0s3"
//Buffer
#define BUF_SIZ 256
unsigned char dest_mac[6] = {0x08, 0x00, 0x27, 0x51, 0xf4, 0x59};

int main()
{
    bool printall = false;
    bool save_raw = false;
    bool dynamic_decoding_window = "true";
    int runs = 10;
    uint64_t max_window_size_var_arr[] = {4, 8, 16, 32, 64}; 
    uint64_t min_window_size_var_arr[] = {4, 8, 16, 32, 64}; 
    string path_filename_packet_delay = "./result/raw_packet_delay";
    string path_filename_in_order_packet_delay = "./result/raw_in_order_packet_delay";
    string path_filename_result = "./result/result";
    string fileid = "_todo_";

    uint64_t max_window_size_var_rx = 128U;
    uint64_t total_source_symbols = 100000U;
    //debug area
    max_window_size_var_rx = 8U;
    total_source_symbols = 100U;

    int var_j_max = sizeof(max_window_size_var_arr) / sizeof(max_window_size_var_arr[0]);

    for (int var_j = 0; var_j < var_j_max; var_j++)
    {
        uint64_t max_window_size_var = max_window_size_var_arr[var_j];
        uint64_t min_window_size_var = min_window_size_var_arr[var_j];
        double avg_delay[runs] = {0};
        double avg_in_order_delay[runs] = {0};
        double PRR[runs] = {0};
        uint64_t timeout = max_window_size_var;

        string filename_packet_delay = path_filename_packet_delay + fileid;
        string filename_in_order_packet_delay = path_filename_in_order_packet_delay + fileid;
        string filename_result = path_filename_result + fileid;

        for (int run_i = 0; run_i < runs; run_i++)
        {
            printf("runs: %d \n", run_i);
            uint64_t num_coded_symbols = 0;
            uint64_t symbol_size = 2U;
            kodo_slide::encoder encoder(symbol_size);
            std::vector<uint8_t> coefficients;
            std::vector<uint8_t> symbol;
            kodo_slide::stream<symbol_ptr> input_symbols;
            uint32_t n= 3;
            uint32_t k= 2;
            kodo_slide::rate_controller rate{n, k};

            uint64_t max_window_size = max_window_size_var; 
            uint64_t min_window_size = min_window_size_var;
            uint64_t current_window_size = max_window_size;

            uint64_t total_transmitted_packets = total_source_symbols / k * n; 
            uint64_t current_pkt_id = 0;
            uint64_t generated = 0;
            uint64_t latest_symbol_id = 0;

            double current_pkt_loss = 0;

            unsigned char packet_data[32 + symbol_size];
            uint8_t print[symbol_size];

            uint64_t max_window_size_rx = max_window_size_var_rx;
            uint64_t min_window_size_rx = max_window_size_rx;
            uint64_t current_window_size_rx = min_window_size_rx;
            bool flag_current_window_size_rx = false; 
            uint64_t symbol_size_rx = 2U;
            kodo_slide::decoder decoder(symbol_size_rx);
            unsigned char packet_data_rx[symbol_size_rx];
            kodo_slide::stream<symbol_ptr> output_symbols;
            kodo_slide::stream<bool> decoded_symbols;

            uint64_t latest_symbol_id_rx = 0;
            uint64_t current_pkt_id_rx = 0;
            uint64_t seed_rx = 0;
            uint64_t num_coded_symbols_rx = 0;
            uint64_t current_window_size_tx_rx = 0;

            int packet_timestamp[total_source_symbols];
            std::fill_n(packet_timestamp, total_source_symbols, -1);

            int in_order_packet_timestamp[total_source_symbols];
            std::fill_n(in_order_packet_timestamp, total_source_symbols, -1);
            int temp_in_order_packet_timestamp = 0;
            uint64_t oldest_index = 0;
            uint64_t decoded = 0;
            while (current_pkt_id < total_transmitted_packets)
            {
                getchar();
                update_link(total_transmitted_packets, current_pkt_id, &current_pkt_loss, max_window_size, min_window_size, &current_window_size, k);
                if (printall)
                {
                    printf("Current Packet ID %lu: \n", current_pkt_id);
                    printf("current windowsize: %lu \n", current_window_size);
                    printf("current packetloss: %f \n", current_pkt_loss);
                }
                if (!rate.send_repair())
                {
                    if (encoder.window_symbols() == max_window_size)
                    {
                        encoder.pop_back_symbol();
                        input_symbols.pop_back();
                    }

                    auto symbol = generate_symbol(symbol_size);
                    if (printall)
                    {
                        std::copy(symbol->begin(), symbol->end(), print);
                        printf("Source Symbol %lu: \n", generated);
                        print_array_uc((unsigned char *)&print, sizeof(print));
                        printf("\n");
                    }
                    encoder.push_front_symbol(symbol->data());
                    input_symbols.push_front(std::move(symbol));

                    num_coded_symbols = 1;
                    ++generated;
                }
                // send coded pkt
                else
                {
                    if (input_symbols.size() < current_window_size)
                    {
                        num_coded_symbols = input_symbols.size();
                    }
                    else
                    {
                        num_coded_symbols = current_window_size;
                    }
                    if (printall)
                    {
                        printf("num_coded_symbol  %lu: \n", num_coded_symbols);
                    }
                }

                latest_symbol_id = generated - 1;

                uint64_t seed = rand();

                // encode based on sliding window size.
                encoder.set_window(encoder.stream_upper_bound() - num_coded_symbols, num_coded_symbols);
                coefficients.resize(encoder.coefficient_vector_size());
                symbol.resize(encoder.symbol_size());
                encoder.set_seed(seed);
                encoder.generate(coefficients.data());
                // why sometimes does symbol.data not update immediately? when does it update
                encoder.write_symbol(symbol.data(), coefficients.data());

                memcpy(&packet_data[0], &latest_symbol_id, 8);  // latest packet
                memcpy(&packet_data[8], &num_coded_symbols, 8); // number of coded symbols
                memcpy(&packet_data[16], &seed, 8);             // seed
                memcpy(&packet_data[24], &k, 4);               
                memcpy(&packet_data[28], &current_pkt_id, 8);   

                std::copy(symbol.begin(), symbol.end(), (uint8_t *)&packet_data[36]);

                ++current_pkt_id;
                rate.advance();
                //if ((double)rand() / (RAND_MAX) < 0.5)
                if ((double)rand() / (RAND_MAX) < current_pkt_loss)
                {
                    if (printall)
                    {
                        printf("Packet lost \n\n");
                    }
                    continue;
                }

                latest_symbol_id_rx = latest_symbol_id;
                num_coded_symbols_rx = num_coded_symbols;
                seed_rx = seed;
                current_pkt_id_rx = current_pkt_id - 1;

                //for fixed decoding window, min_window_size_rx = max_window_size_rx
                if (dynamic_decoding_window)
                {
                    min_window_size_rx = k;
                    if (!flag_current_window_size_rx)
                    {
                        flag_current_window_size_rx = true;
                        current_window_size_rx = min_window_size_rx;
                    }
                }
                while (decoder.stream_symbols() < min_window_size_rx)
                {
                    auto symbol = make_symbol(symbol_size);
                    decoder.push_front_symbol(symbol->data());
                    output_symbols.push_front(std::move(symbol));
                    decoded_symbols.push_front(false);
                }

                int window_size_rx_change = 0;
                uint64_t temp_window_size_rx = 0;

                // last packet    [8x|1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16]  wd=24
                // current packet [4x 1 2 3 4|5 6 7 8 9 10 11 12 13 14 15 16]  wd=20

                // last packet    [8x|1 2 3 4 5 6 7 8]  wd=16
                // current packet [   1 2 3 4|5 6 7 8]  wd=8
                // 1 2 3 4 get dropped

                if (num_coded_symbols > 1) 
                {
                    // update current_window_size_tx_rx
                    current_window_size_tx_rx = num_coded_symbols;
                    // update current_window_size_rx:
                    //      receiver window = max(1.5(tbd)*transmiter window,  window size min)
                    //      receiver window = int time of window size min
                    //      receiver window should not exceed max window size

                    temp_window_size_rx = ceil(current_window_size_tx_rx * 1.5 / min_window_size_rx) * min_window_size_rx;
                    temp_window_size_rx = min(max_window_size_rx, temp_window_size_rx);
                    window_size_rx_change = temp_window_size_rx - current_window_size_rx;
                    current_window_size_rx = temp_window_size_rx;

                    if (window_size_rx_change >= 0 && decoder.stream_symbols() < max_window_size_rx)
                    {

                        for (int i = 0; i < window_size_rx_change; i++)
                        {
                            auto symbol = make_symbol(symbol_size);
                            decoder.push_front_symbol(symbol->data());
                            output_symbols.push_front(std::move(symbol));
                            decoded_symbols.push_front(false);
                        }
                    }
                    // window size decreased, just remove out of date packets
                    // [] start
                    // [e e e e] increase
                    // [d d d d] decode
                    // [d d d e] decrease
                    // [d d e e] decrease
                    // [d d e e e e] increase
                    // [d d d d d d] decode
                    // [d d d d d d e e] increase (reach max)
                    // [d d d d d d d d] decode
                    // [d d d d e e e e] decrease
                    // [d d d d e e e e] new packet
                    // [d d e e e e e e] decrease
                    else
                    {
                        for (int i = 0; i < (0 - window_size_rx_change); i++)
                        {
                            // for the last x= current_window_size_rx source symbols
                            oldest_index = decoder.stream_lower_bound();
                            if (packet_timestamp[oldest_index] != -1)
                            {
                                if (packet_timestamp[oldest_index] < temp_in_order_packet_timestamp)
                                {
                                    in_order_packet_timestamp[oldest_index] = temp_in_order_packet_timestamp;
                                }
                                else
                                {
                                    in_order_packet_timestamp[oldest_index] = packet_timestamp[oldest_index];
                                    temp_in_order_packet_timestamp = packet_timestamp[oldest_index];
                                }
                                // if(((int)current_pkt_id_rx - packet_timestamp[oldest_index])<(int)timeout)
                                // {

                                // }
                            }
                            else 
                            {
                                temp_in_order_packet_timestamp = (int)current_pkt_id_rx;
                            }
                            decoder.pop_back_symbol();
                            auto symbol = std::move(output_symbols.back());
                            output_symbols.pop_back();
                            decoded_symbols.pop_back();
                            decoder.push_front_symbol(symbol->data());
                            output_symbols.push_front(std::move(symbol));
                            decoded_symbols.push_front(false);
                        }
                    }
                }

                //while (decoder.stream_upper_bound() <= latest_symbol_id_rcv)
                while (decoder.stream_lower_bound() + current_window_size_rx <= latest_symbol_id_rx)
                {
                    oldest_index = decoder.stream_lower_bound();
                    if (packet_timestamp[oldest_index] != -1)
                    {
                        if (packet_timestamp[oldest_index] < temp_in_order_packet_timestamp)
                        {
                            in_order_packet_timestamp[oldest_index] = temp_in_order_packet_timestamp;
                        }
                        else
                        {
                            in_order_packet_timestamp[oldest_index] = packet_timestamp[oldest_index];
                            temp_in_order_packet_timestamp = packet_timestamp[oldest_index];
                        }
                    }
                    else 
                    {
                        temp_in_order_packet_timestamp = (int)current_pkt_id_rx;
                    }

                    decoder.pop_back_symbol();
                    auto symbol = std::move(output_symbols.back());
                    output_symbols.pop_back();
                    decoded_symbols.pop_back();

                    decoder.push_front_symbol(symbol->data());
                    output_symbols.push_front(std::move(symbol));
                    decoded_symbols.push_front(false);
                }

                // in case all coded packet lost, wd 0-8,1-9,2-10...11-19,
                // coded packet comes 0-19 , wd 11-43
                // current solution, drop this for better latency performance

                // only decode when packet is in current window. Second condition shall be unnecessary, this can be captured in the conditions before
                if (decoder.stream_lower_bound() > (latest_symbol_id_rx - num_coded_symbols_rx + 1) || (decoder.stream_lower_bound() + current_window_size_rx) <= latest_symbol_id_rx)
                {
                    continue;
                }
                decoder.set_window(latest_symbol_id_rx - num_coded_symbols_rx + 1,
                                   num_coded_symbols_rx);

                decoder.set_seed(seed_rx);
                coefficients.resize(num_coded_symbols_rx); 
                symbol.resize(decoder.symbol_size());

                decoder.generate(coefficients.data()); // generate coding coefficient 
                decoder.read_symbol(symbol.data(), coefficients.data());

                for (uint64_t i = 0; i < decoder.stream_symbols(); ++i)
                {
                    uint64_t index = i + decoder.stream_lower_bound();

                    if (!decoder.is_symbol_decoded(index))
                    {
                        continue;
                    }
                    if (decoded_symbols[index] == true)
                    {
                        continue;
                    }
                    ++decoded;
                    decoded_symbols[index] = true;

                    if (printall)
                    {
                        std::cout << "Decoded index = " << index << "\n";
                        std::copy(output_symbols.at(index)->begin(), output_symbols.at(index)->end(), (uint8_t *)&packet_data_rx[0]); // symbol
                        print_array_uc((unsigned char *)&packet_data_rx, sizeof(packet_data_rx));
                        printf("\n\n");
                    }

                    packet_timestamp[index] = (int)current_pkt_id_rx;
                }
            }
            for (oldest_index = decoder.stream_lower_bound(); oldest_index <= latest_symbol_id_rx; oldest_index++)
            {
                if (packet_timestamp[oldest_index] != -1) 
                {
                    if (packet_timestamp[oldest_index] < temp_in_order_packet_timestamp)
                    {
                        in_order_packet_timestamp[oldest_index] = temp_in_order_packet_timestamp;
                    }
                    else
                    {
                        in_order_packet_timestamp[oldest_index] = packet_timestamp[oldest_index];
                        temp_in_order_packet_timestamp = packet_timestamp[oldest_index];
                    }
                }
                else
                {
                    temp_in_order_packet_timestamp = (int)current_pkt_id_rx;
                }
            }
            //td exclude first max_window_size_rx packets and last max_window_size_rx packets
            int packet_delay[total_source_symbols];
            std::fill_n(packet_delay, total_source_symbols, -1);
            int sum_delay = 0;

            int in_order_packet_delay[total_source_symbols];
            std::fill_n(in_order_packet_delay, total_source_symbols, -1);
            int sum_in_order_delay = 0;

            for (uint64_t i = 0; i <= latest_symbol_id_rx; i++)
            {
                //maybe td: (decoded time - decoded index (generate time without NC))
                div_t divresult = div((int)i, (int)k);
                if (packet_timestamp[i] != -1)
                {
                    packet_delay[i] = (int)(packet_timestamp[i] - (divresult.quot * n + divresult.rem));
                    sum_delay += packet_delay[i];
                }
                if (in_order_packet_timestamp[i] != -1)
                {
                    in_order_packet_delay[i] = (int)(in_order_packet_timestamp[i] - (divresult.quot * n + divresult.rem));
                    sum_in_order_delay += in_order_packet_delay[i];
                }
            }
            avg_delay[run_i] = (double)sum_delay / (double)decoded;
            avg_in_order_delay[run_i] = (double)sum_in_order_delay / (double)decoded;
            PRR[run_i] = (double)decoded / (double)total_source_symbols;

            if (save_raw)
            {
                //CDF
                fstream myfile;
                myfile.open(filename_packet_delay, fstream::app | fstream::out);
                for (int i = 0; i < total_source_symbols; i++)
                {
                    myfile << packet_delay[i] << "\t";
                }
                myfile << std::endl
                       << std::endl;
                myfile.close();

                myfile.open(filename_in_order_packet_delay, fstream::app | fstream::out);
                for (int i = 0; i < total_source_symbols; i++)
                {
                    myfile << in_order_packet_delay[i] << "\t";
                }
                myfile << std::endl
                       << std::endl;
                myfile.close();
            }
        }

        if (save_raw)
        {
            fstream myfile;
            myfile.open(filename_result, fstream::app | fstream::out);
            myfile << "average delay:";
            double average = 0;
            for (int i = 0; i < runs; i++)
            {
                myfile << avg_delay[i] << "\t";
                average += avg_delay[i];
            }
            average = average / runs;
            myfile << "average: " << average << "\t";

            average = 0;
            myfile << std::endl
                   << "average in order packet delay:";
            for (int i = 0; i < runs; i++)
            {
                myfile << avg_in_order_delay[i] << "\t";
                average += avg_in_order_delay[i];
            }
            average = average / runs;
            myfile << "average: " << average << "\t";

            average = 0;
            myfile << std::endl
                   << "PRR:";
            for (int i = 0; i < runs; i++)
            {
                myfile << PRR[i] << "\t";
                average += PRR[i];
            }
            average = average / runs;
            myfile << "average: " << average << "\t";

            myfile << std::endl
                   << std::endl;
            myfile.close();
        }
        else
        {
            fstream myfile;
            myfile.open(filename_result, fstream::app | fstream::out);
            myfile << "window_" << max_window_size_var << "_" << min_window_size_var << "\t";
            double average = 0;
            for (int i = 0; i < runs; i++)
            {
                average += avg_delay[i];
            }
            average = average / runs;
            myfile << average << "\t\t";

            average = 0;
            for (int i = 0; i < runs; i++)
            {
                average += avg_in_order_delay[i];
            }
            average = average / runs;
            myfile << average << "\t\t";

            average = 0;
            for (int i = 0; i < runs; i++)
            {
                average += PRR[i];
            }
            average = average / runs;
            myfile << average << "\t\t";

            myfile << std::endl;
            myfile.close();
        }
    }

    //json j;
    //std::ofstream o("result.json");
    //o << std::setw(4) << j << std::endl;

    return 0;
}

//why max in order latency > window size receiver
