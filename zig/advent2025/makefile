DAYS = day01 day02 day03 day04 day05 day06 day07 day08 day09 day10 day11 day12
BENCHOPT = -O ReleaseFast


$(DAYS): $(@:.zig=)
	zig build-exe $@.zig $(BENCHOPT)

exe: $(DAYS)

bench: $(DAYS)
	@for d in $(DAYS); do \
            echo $$d; \
            t0=`date +%s%3N`; \
            ./$$d; \
            t1=`date +%s%3N`; \
            echo "\t\t\t$$((t1-t0))ms"; \
        done

bench-all: $(DAYS)
	t0=`date +%s%3N`; \
	for d in $(DAYS); do \
            echo $$d; \
            ./$$d; \
        done; \
	t1=`date +%s%3N`; \
	echo "\t\t\t$$((t1-t0))ms"

clean:
	rm -f $(DAYS)

