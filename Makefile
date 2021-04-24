ifeq ($(OS),Windows_NT)
	remove = del
	path_sep = \\
else
	remove = rm
	path_sep = /
endif

MAPS = $(wildcard asset/map/*)
MAPS_EXPORTED = $(patsubst asset/map/%.tmx,asset/map_export/%.json,$(MAPS))

.PHONY: run build rebuild tiled

run: build
	"./run" $(PROGRAM_ARGS)

rebuild: clean build
build: tiled

tiled: $(MAPS_EXPORTED)

asset/map_export/%.json: asset/map/%.tmx
	tiled --export-map json "$<" "$@"

clean:
	$(remove) $(subst /,$(path_sep),$(wildcard asset/map_export/*.json))
