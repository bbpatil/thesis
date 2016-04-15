/*
 * Data.cc
 *
 *  Created on: Mar 23, 2016
 *      Author: franz
 */

#include "Data.h"



// Packing functions
void doPacking(cCommBuffer *buffer, Data& data)
{
    buffer->pack(static_cast<int>(data.type));
    buffer->pack(&(data.data[0]), data.data.size());
}

void doUnpacking(cCommBuffer *buffer, Data& data)
{
    int typeVal;
    buffer->unpack(typeVal);
    data.type = static_cast<DataType>(typeVal);
    buffer->unpack(&(data.data[0]), data.data.size());
}
