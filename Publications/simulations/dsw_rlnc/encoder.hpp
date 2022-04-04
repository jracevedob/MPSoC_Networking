#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
#include <iostream>
#include <vector>
#include <memory>

#include <stream.hpp>
#include <galois_field.hpp>
#include <symbol.hpp>
#include <socket.hpp>
using symbol_ptr = std::unique_ptr<std::vector<uint8_t>>;

uint64_t generate_coefficients(std::vector<uint8_t> *coefficients)
{
    uint64_t size = coefficients->size();
    uint64_t seed = rand();
    srand(seed);
    coefficients->at(0) = 1;
    for (uint64_t i = 1; i < size; i++)
    {
        coefficients->at(i) = rand();
    }
    //printf("coeff: ");
    //print_packet(coefficients);
    return seed;
}

// encode a packet based on input_symbols and coefficients
void generate_pkt(std::vector<uint8_t> *coded_pkt, stream<symbol_ptr> *input_symbols, std::vector<uint8_t> *coefficients)
{
    uint64_t latest_symbol_id = input_symbols->upper_bound() - 1;
    uint64_t num_coded_symbols = coefficients->size();
    uint64_t symbol_size = input_symbols->at(latest_symbol_id)->size();
    
    *coded_pkt = *input_symbols->at(latest_symbol_id);
    galois_w08_region_multiply(&(coded_pkt->at(0)), coefficients->at(0), symbol_size, NULL, 1);
    for (uint64_t i = 1; i < num_coded_symbols; i++)
    {
        galois_w08_region_multiply(&(*input_symbols->at(latest_symbol_id - i))[0], coefficients->at(i), symbol_size, &(coded_pkt->at(0)), 1);
    }
}

// encode a packet 
uint64_t encode_pkt(std::vector<uint8_t> *coded_pkt, stream<symbol_ptr> *input_symbols, uint64_t num_coded_symbols)
{
    std::vector<uint8_t> coefficients;
    coefficients.resize(num_coded_symbols);

    uint64_t seed = generate_coefficients(&coefficients);
    generate_pkt(coded_pkt, input_symbols, &coefficients);
    return seed;
}
