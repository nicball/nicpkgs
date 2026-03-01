{ super, fetchurl }:

super.less.overrideAttrs (finalAttrs: _: {
  version = "692";
  src = fetchurl {
    url = "https://www.greenwoodsoftware.com/less/less-${finalAttrs.version}.tar.gz";
    hash = "sha256-YTAPYDeY7PHXeGVweJ8P8/WhrPB1pvufdWg30WbjfRQ=";
  };
})
