#ifndef DATAMSG_H
#define DATAMSG_H
#define MAXBIKES 10

typedef nx_struct EasyDisseminationMsg {
    nx_uint16_t bikes[MAXBIKES];
  } EasyDisseminationMsg;
  
  
  typedef nx_struct EasyCollectionMsg {
    nx_uint16_t data[20];
  } EasyCollectionMsg;
  
#endif
