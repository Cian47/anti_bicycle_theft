/**
* @author Kevin Freeman
* @author Martin Schwarzmaier
*/

#ifndef DATAMSG_H
#define DATAMSG_H
#define MAXBIKES 10
#define COORDS_PER_PACKET 2

typedef nx_struct EasyDisseminationMsg 
{
    nx_uint16_t bikes[MAXBIKES];
} EasyDisseminationMsg;

//size = 2+4+(12*COORDS_PER_PACKET)
/* keep in mind, that 114 is max size 
* so COORDS_PER_PACKET may be max equal 9 at the moment
*/
typedef nx_struct EasyCollectionMsg 
{
    nx_uint16_t nodeid;
    nx_uint32_t current_time;
    nx_uint32_t time[COORDS_PER_PACKET];
    nx_uint32_t lat[COORDS_PER_PACKET];
    nx_uint32_t lon[COORDS_PER_PACKET];
} EasyCollectionMsg;
  
#endif
