CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -Wextra

.PHONY: all clean

writer: writer.o
	$(CC) $(CFLAGS) $^ -o $@

writer.o: writer.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf $(TARGET) *.o
