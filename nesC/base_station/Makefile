COMPONENT=BaseStationAppC
CFLAGS += -DCC2420_NO_ACKNOWLEDGEMENTS
CFLAGS += -DCC2420_NO_ADDRESS_RECOGNITION
CFLAGS += -DTASKLET_IS_TASK
CFLAGS += -I$(TOSDIR)/lib/net \
          -I$(TOSDIR)/lib/net/le \
          -I$(TOSDIR)/lib/net/ctp \
          -I$(TOSDIR)/lib/net/drip \
          -I ../
          
MSG_SIZE = 114
include $(MAKERULES)

