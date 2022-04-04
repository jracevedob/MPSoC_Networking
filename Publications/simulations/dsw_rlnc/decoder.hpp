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


#define mat(stream_name, r, c) stream_name->at(r)->at(c)
using symbol_ptr = std::unique_ptr<std::vector<uint8_t>>;

void print_matrix(stream<symbol_ptr> *matrix);

void swap_rows(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, uint64_t row_1, uint64_t row_2);

void swap_rows_single_mat(stream<symbol_ptr> *matrix, uint64_t row_1, uint64_t row_2);

void normalize_row(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, uint64_t row, uint64_t column_lead);

void normalize_row_single_mat(stream<symbol_ptr> *matrix, uint64_t row, uint8_t lead_value);

void mult_and_add_rows(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, uint64_t row_dest, uint64_t row_src, uint8_t mult);

void mult_and_add_rows_single_mat(stream<symbol_ptr> *matrix, uint64_t row_dest, uint64_t row_src, uint8_t mult);

void stream_elimination(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols);

uint64_t decode_pkt(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, stream<bool> *decoded_symbols);

bool find_decoded_pkt(stream<symbol_ptr> *coeff_stream, uint64_t row, uint64_t *decoded_index);

bool log_decoded_pkt(stream<bool> *decoded_symbols, uint64_t decoded_index);

void handle_decoded_pkt(stream<symbol_ptr> *output_symbols, uint64_t decoded_index, uint64_t row);

void generate_coefficients_rcv(std::vector<uint8_t> *coefficients_rcv,uint64_t num_coded_symbols,uint64_t seed);
void write_coefficients_rcv(std::vector<uint8_t> *coefficients_rcv,stream<symbol_ptr> *coefficients_stream, uint64_t latest_symbol_id_rcv);
void handle_coefficient_rcv(std::vector<uint8_t> *coefficients_rcv,stream<symbol_ptr> *coefficients_stream, uint64_t latest_symbol_id_rcv,uint64_t num_coded_symbols_rcv,uint64_t seed_rcv);

void print_matrix(stream<symbol_ptr> *matrix)
{
    uint64_t row_start = matrix->lower_bound();
    uint64_t row_size = matrix->size();
    uint64_t row_end = row_start + row_size;
    uint64_t column_size = matrix->at(row_start)->size();
    const char *sc;
    for (uint64_t row = row_start; row < row_end; row++)
    {
        printf("   ");
        sc = " ";
        for (uint64_t column = 0; column < column_size; column++)
        {
            printf("%s %u", sc, (unsigned char)mat(matrix, row, column));
            sc = ",";
        }
        printf("\n");
    }
    printf("\n");
}

void swap_rows(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, uint64_t row_1, uint64_t row_2)
{
    swap_rows_single_mat(coeff_stream, row_1, row_2);
    swap_rows_single_mat(output_symbols, row_1, row_2);
}

//swap row rix1 with rix2
void swap_rows_single_mat(stream<symbol_ptr> *matrix, uint64_t row_1, uint64_t row_2)
{
    if (row_1 == row_2)
    {
        return;
    }
    uint8_t temp;
    uint64_t row_start = matrix->lower_bound();
    uint64_t column_size = matrix->at(row_start)->size();
    std::vector<uint8_t> row;
    row.resize(column_size);
    row = *matrix->at(row_1);
    *matrix->at(row_1) = *matrix->at(row_2);
    *matrix->at(row_2) = row;
    row.clear();
}

void normalize_row(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, uint64_t row, uint64_t column_lead)
{
    uint8_t lead_value = galois_single_divide(1, mat(coeff_stream, row, column_lead));
    normalize_row_single_mat(coeff_stream, row, lead_value);
    normalize_row_single_mat(output_symbols, row, lead_value);
}

void normalize_row_single_mat(stream<symbol_ptr> *matrix, uint64_t row, uint8_t lead_value)
{
    uint64_t column_size = matrix->at(row)->size();
    galois_w08_region_multiply(&(*matrix->at(row))[0], lead_value, column_size, NULL, 0);
}

// row dest += row source * multiplyer
void mult_and_add_rows(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, uint64_t row_dest, uint64_t row_src, uint8_t mult)
{
    mult_and_add_rows_single_mat(coeff_stream, row_dest, row_src, mult);
    mult_and_add_rows_single_mat(output_symbols, row_dest, row_src, mult);
}

// row dest += row source * multiplyer
void mult_and_add_rows_single_mat(stream<symbol_ptr> *matrix, uint64_t row_dest, uint64_t row_src, uint8_t mult)
{
    uint64_t column_size = matrix->at(row_dest)->size();
    galois_w08_region_multiply(&(*matrix->at(row_src))[0], mult, column_size, &(*matrix->at(row_dest))[0], 1);
}

// reduce both coefficient matrix into row echelon form
void stream_elimination(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols)
{
    uint64_t column_lead = 0;
    uint64_t row_1, row_2;
    uint8_t lead_value;
    uint64_t row_start = coeff_stream->lower_bound();
    uint64_t row_size = coeff_stream->size();
    uint64_t row_end = row_start + row_size;
    uint64_t column_size = row_size;
    int print_enable = 0;

    for (row_1 = row_start; row_1 < row_end; row_1++)
    {
        if (column_lead >= column_size)
        {
            if (print_enable)
            {
                print_matrix(coeff_stream);
                print_matrix(output_symbols);
            }
            return;
        }
        row_2 = row_1;
        while (mat(coeff_stream, row_2, column_lead) == 0) 
        {
            row_2++;
            if (row_2 == row_end) 
            {
                row_2 = row_1;
                column_lead++;
                if (column_lead == column_size)
                {
                    if (print_enable)
                    {
                        print_matrix(coeff_stream);
                        print_matrix(output_symbols);
                    }
                    return;
                }
            }
        }
        if (print_enable)
        {
            print_matrix(coeff_stream);
            print_matrix(output_symbols);
        }
        swap_rows(coeff_stream, output_symbols, row_2, row_1);
        if (print_enable)
        {
            print_matrix(coeff_stream);
            print_matrix(output_symbols);
        }
        normalize_row(coeff_stream, output_symbols, row_1, column_lead);
        if (print_enable)
        {
            print_matrix(coeff_stream);
            print_matrix(output_symbols);
        }
        for (row_2 = row_start; row_2 < row_end; row_2++)
        {
            if (row_2 != row_1)
            {
                lead_value = mat(coeff_stream, row_2, column_lead);
                mult_and_add_rows(coeff_stream, output_symbols, row_2, row_1, lead_value);
                if (print_enable)
                {
                    print_matrix(coeff_stream);
                    print_matrix(output_symbols);
                }
            }
        }
        column_lead++;
    }
    if (print_enable)
    {
        print_matrix(coeff_stream);
        print_matrix(output_symbols);
    };
}

uint64_t decode_pkt(stream<symbol_ptr> *coeff_stream, stream<symbol_ptr> *output_symbols, stream<bool> *decoded_symbols, uint64_t latency_vector[], uint64_t current_pkt_id_rcv)
{
    uint64_t num_of_decoded_symbols = 0;
    uint64_t decoded_index;

    uint64_t row_start = coeff_stream->lower_bound();
    uint64_t row_size = coeff_stream->size();
    uint64_t row_end = row_start + row_size;
    uint64_t coeff_column_size = row_size;

    for (uint64_t row = row_start; row < row_end; row++)
    {
        if (find_decoded_pkt(coeff_stream, row, &decoded_index))
        {
            if (log_decoded_pkt(decoded_symbols, decoded_index))
            {
                uint64_t latency = (current_pkt_id_rcv-1)-decoded_index*2;
                latency_vector[decoded_index] =latency; 
                num_of_decoded_symbols++;
            }
        }
    }
    return num_of_decoded_symbols;
}

bool find_decoded_pkt(stream<symbol_ptr> *coeff_stream, uint64_t row, uint64_t *decoded_index)
{
    uint64_t non_zero = 0;
    uint64_t row_size = coeff_stream->size();
    uint64_t coeff_column_size = row_size;

    for (uint64_t column = 0; column < coeff_column_size; column++)
    {
        if (mat(coeff_stream, row, column) != 0)
        {
            non_zero++;
            *decoded_index = column;
        }
    }
    if (non_zero == 1)
    {
        *decoded_index += coeff_stream->lower_bound();
        return true;
    }
    else
    {
        return false;
    }
}

bool log_decoded_pkt(stream<bool> *decoded_symbols, uint64_t decoded_index)
{

    if (decoded_symbols->at(decoded_index))
    {
        return false;
    }
    else
    {
        decoded_symbols->at(decoded_index) = true;
        return true;
    }
}

void handle_decoded_pkt(stream<symbol_ptr> *output_symbols, uint64_t decoded_index, uint64_t row)
{
    uint64_t column_size = output_symbols->at(row)->size();
    for (uint64_t column = 0; column < column_size; column++)
    {
        printf(" %u", (unsigned char)mat(output_symbols, row, column));
    }
    printf("\n");
}

void generate_coefficients_rcv(std::vector<uint8_t> *coefficients_rcv,uint64_t num_coded_symbols_rcv,uint64_t seed_rcv)
{
    srand(seed_rcv);
    coefficients_rcv->resize(num_coded_symbols_rcv);
    coefficients_rcv->at(num_coded_symbols_rcv-1) = 1;
    for(uint64_t i = 1 ; i < num_coded_symbols_rcv;i++)
    {
        coefficients_rcv->at(num_coded_symbols_rcv-1-i) = rand();
    }
}

void write_coefficients_rcv(std::vector<uint8_t> *coefficients_rcv,stream<symbol_ptr> *coefficients_stream, uint64_t latest_symbol_id_rcv)
{
    uint64_t num_coded_symbols = coefficients_rcv->size();
    uint64_t oldest_symbol_id = latest_symbol_id_rcv - num_coded_symbols +1;
    uint64_t offset = oldest_symbol_id - coefficients_stream->lower_bound();
    
    auto coefficients_temp = generate_empty_symbol(coefficients_stream->at(coefficients_stream->upper_bound()-1)->size());
    copy(coefficients_rcv->begin(),coefficients_rcv->end(), coefficients_temp->begin()+offset);
    *coefficients_stream->at(coefficients_stream->upper_bound()-1) = *coefficients_temp;
    coefficients_temp.reset();
}

void handle_coefficient_rcv(std::vector<uint8_t> *coefficients_rcv,stream<symbol_ptr> *coefficients_stream, uint64_t latest_symbol_id_rcv,uint64_t num_coded_symbols_rcv,uint64_t seed_rcv)
{
    generate_coefficients_rcv(coefficients_rcv, num_coded_symbols_rcv,seed_rcv);
    write_coefficients_rcv(coefficients_rcv, coefficients_stream, latest_symbol_id_rcv);
}

void handle_packet_rcv(std::vector<uint8_t> *packet_rcv,stream<symbol_ptr> *output_symbols)
{
    *output_symbols->at(output_symbols->upper_bound()-1) = *packet_rcv;
}
void clear_last_coeff(stream<symbol_ptr> *coeff_stream)
{
    uint64_t size = coeff_stream->at(coeff_stream->upper_bound()-1)->size();
    for(uint64_t i = 0; i<size; i++)
    {
        coeff_stream->at(coeff_stream->upper_bound()-1)->at(i) = 0;
    }
}

void clear_last_symbol(stream<symbol_ptr> *output_symbols)
{
    uint64_t size = output_symbols->at(output_symbols->upper_bound()-1)->size();
    for(uint64_t i = 0; i<size; i++)
    {
        output_symbols->at(output_symbols->upper_bound()-1)->at(i) = 0;
    }
}