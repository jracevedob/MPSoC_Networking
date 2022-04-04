#pragma once
#include <cassert>
#include <cstdint>
#include <deque>


template <class Type>
struct stream
{

    uint64_t size() const
    {
        return m_stream.size();
    }



    uint64_t lower_bound() const
    {
        return m_stream_offset;
    }


    uint64_t upper_bound() const
    {
        return m_stream_offset + m_stream.size();
    }


    uint64_t push_front(const Type& element)
    {
        m_stream.push_back(element);
        return m_stream_offset + (m_stream.size() - 1);
    }


    uint64_t push_front(Type&& data)
    {
        m_stream.push_back(std::move(data));
        return m_stream_offset + (m_stream.size() - 1);
    }


    uint64_t pop_back()
    {
        assert(m_stream.size() > 0U);

        m_stream.pop_front();
        return m_stream_offset++;
    }


    void reset()
    {
        m_stream.resize(0U);
        m_stream_offset = 0U;
    }


    Type& back()
    {
        assert(size() > 0U);
        return at(lower_bound());
    }


    const Type& back() const
    {
        assert(size() > 0U);
        return at(lower_bound());
    }


    Type& at(uint64_t index)
    {
        assert(index >= m_stream_offset);
        assert(index < m_stream_offset + m_stream.size());
        uint64_t mapped_index = index - m_stream_offset;
        assert(mapped_index < m_stream.size());

        return m_stream[mapped_index];
    }

    const Type& at(uint64_t index) const
    {
        assert(index >= m_stream_offset);
        assert(index < m_stream_offset + m_stream.size());


        uint16_t mapped_index = index - m_stream_offset;
        assert(mapped_index < m_stream.size());

        return m_stream[mapped_index];
    }

    const Type& operator[](uint64_t index) const
    {
        return at(index);
    }

    Type& operator[](uint64_t index)
    {
        return at(index);
    }

    bool in_stream(uint64_t index) const
    {
        if (index < lower_bound())
        {
            return false;
        }

        if (index >= upper_bound())
        {
            return false;
        }

        return true;
    }

    friend auto begin(const stream& r)
    {
        return r.m_stream.begin();
    }

    friend auto begin(stream& r)
    {
        return r.m_stream.begin();
    }


    friend auto end(const stream& r)
    {
        return r.m_stream.end();
    }

    friend auto end(stream& r)
    {
        return r.m_stream.end();
    }

public:

    uint64_t m_stream_offset = 0;
    std::deque<Type> m_stream;
};
