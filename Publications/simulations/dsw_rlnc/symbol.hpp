#pragma once
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <algorithm>
#include <iostream>
#include <vector>
#include <memory>


using symbol_ptr = std::unique_ptr<std::vector<uint8_t>>;

// vector
void get_symbol_from_app(symbol_ptr *symbol_pointer)
{ 

    static uint8_t num = 1;
    uint8_t x = 0;
    int64_t size = (*symbol_pointer)->size();
    for(uint64_t i = 0; i < size; i++)
    {
        (*symbol_pointer)->at(i) = num+x;
        x++;
    }
    num++;
}

void zero_generator(symbol_ptr *symbol_pointer)
{ 
    int64_t size = (*symbol_pointer)->size();
    for(uint64_t i = 0; i < size; i++)
    {
        (*symbol_pointer)->at(i) = 0;
    }
}

void print_symbol_ptr(symbol_ptr *symbol_pointer)
{ 
    uint64_t size = (*symbol_pointer)->size();
    for(uint64_t i = 0; i < size; i++)
    {
         printf("%u ", (unsigned char)(*symbol_pointer)->at(i));
    }
    printf("\n");
}

symbol_ptr make_symbol(uint64_t size)
{
    symbol_ptr data = std::make_unique<std::vector<uint8_t>>();
    data->resize(size);
    return data;
}

symbol_ptr generate_empty_symbol(uint64_t size)
{
    symbol_ptr data = make_symbol(size);
    zero_generator(&data);
    return data;
}

symbol_ptr generate_symbol(uint64_t size)
{
    symbol_ptr data = make_symbol(size);
    //std::generate(data->begin(), data->end(), rand);
    get_symbol_from_app(&data);
    print_symbol_ptr(&data);
    return data;
}



