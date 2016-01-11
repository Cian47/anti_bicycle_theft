#ifndef DATAMSG_H
#define DATAMSG_H
#define MAXBIKES 10
#define COORDS 2

typedef nx_struct EasyDisseminationMsg {
    nx_uint16_t bikes[MAXBIKES];
  } EasyDisseminationMsg;
  
  
  typedef nx_struct EasyCollectionMsg {
    nx_uint16_t nodeid[COORDS];
    nx_uint32_t time[COORDS];
    nx_uint32_t lat[COORDS];
    nx_uint32_t lon[COORDS];
  } EasyCollectionMsg;
  
#endif
