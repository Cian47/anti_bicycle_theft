anti_bicycle_theft
Anti bicycle theft implemented in TinyOS+nodeJS. 

This project will need mts420-cc boards including GPS antennas. 

There are three types of motes:
- bicycle motes
- network nodes
- a base station

Each bicycle is equipped with one mote and gps antenna. Network nodes are just disseminating and collecting data. The base stations uses the SerialForwarder to put data into the network and gather data from the network nodes. 
