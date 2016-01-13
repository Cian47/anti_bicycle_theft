#ifndef DATAMSG_H
#define DATAMSG_H
#define MAXBIKES 10
#define COORDS_PER_PACKET 2

typedef nx_struct EasyDisseminationMsg {
    nx_uint16_t bikes[MAXBIKES];
  } EasyDisseminationMsg;
  
  
  typedef nx_struct EasyCollectionMsg {
    nx_uint16_t nodeid;
    nx_uint32_t current_time;
    nx_uint32_t time[COORDS_PER_PACKET];
    nx_uint32_t lat[COORDS_PER_PACKET];
    nx_uint32_t lon[COORDS_PER_PACKET];
  } EasyCollectionMsg;
  
#endif
