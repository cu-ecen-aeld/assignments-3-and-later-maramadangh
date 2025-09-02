CC ?= gcc
CFLAGS ?= -Wall -Wextra
LDFLAGS ?= -lpthread
TARGET = aesdsocket
SRCS = aesdsocket.c
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) -o $(TARGET)

$(OBJS): $(SRCS)
	$(CC) $(CFLAGS) -c $(SRCS) -o $(OBJS)

clean:
	rm -f $(OBJS) $(TARGET)
