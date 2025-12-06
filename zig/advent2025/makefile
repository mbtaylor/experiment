DAYS = day01 day02 day03 day04 day05 day06
BENCHOPT = -O ReleaseFast


$(DAYS): $(DAYS:=.zig)
	zig build-exe $@.zig $(BENCHOPT)

bench: $(DAYS)
	@for d in $(DAYS); do \
            echo $$d; \
            t0=`date +%s%3N`; \
            ./$$d; \
            t1=`date +%s%3N`; \
            echo "\t\t\t$$((t1-t0))ms"; \
        done

clean:
	rm -f $(DAYS)

