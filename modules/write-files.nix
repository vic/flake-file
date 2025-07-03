{

  perSystem =
    { config, ... }:
    {
      packages.write-files = config.files.writer.drv;
    };

}
