#pragma once

#include <cassert>
#include <cstdint>

struct rate_controller
{
    rate_controller(uint16_t n, uint16_t k) :
        m_n(n), m_k(k)
    {
        assert(m_n > 0);
        assert(m_k > 0);
        assert(m_n >= m_k);
    }

    void advance()
    {
        assert(m_position < m_n);

        m_position = (m_position + 1) % m_n;

        assert(m_position < m_n);
    }

    bool send_repair() const
    {
        return m_position >= m_k;
    }
private:
    uint16_t m_n = 0;
    uint16_t m_k = 0;
    uint16_t m_position = 0;
};
