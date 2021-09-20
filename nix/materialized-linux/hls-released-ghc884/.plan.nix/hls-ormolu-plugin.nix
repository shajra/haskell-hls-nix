{ system
  , compiler
  , flags
  , pkgs
  , hsPkgs
  , pkgconfPkgs
  , errorHandler
  , config
  , ... }:
  {
    flags = {};
    package = {
      specVersion = "2.4";
      identifier = { name = "hls-ormolu-plugin"; version = "1.0.1.0"; };
      license = "Apache-2.0";
      copyright = "The Haskell IDE Team";
      maintainer = "alan.zimm@gmail.com";
      author = "The Haskell IDE Team";
      homepage = "";
      url = "";
      synopsis = "Integration with the Ormolu code formatter";
      description = "Please see the README on GitHub at <https://github.com/haskell/haskell-language-server#readme>";
      buildType = "Simple";
      isLocal = true;
      detailLevel = "FullDetails";
      licenseFiles = [ "LICENSE" ];
      dataDir = ".";
      dataFiles = [];
      extraSrcFiles = [ "LICENSE" "test/testdata/**/*.hs" ];
      extraTmpFiles = [];
      extraDocFiles = [];
      };
    components = {
      "library" = {
        depends = [
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
          (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
          (hsPkgs."ghc-boot-th" or (errorHandler.buildDepError "ghc-boot-th"))
          (hsPkgs."ghcide" or (errorHandler.buildDepError "ghcide"))
          (hsPkgs."hls-plugin-api" or (errorHandler.buildDepError "hls-plugin-api"))
          (hsPkgs."lens" or (errorHandler.buildDepError "lens"))
          (hsPkgs."lsp" or (errorHandler.buildDepError "lsp"))
          (hsPkgs."ormolu" or (errorHandler.buildDepError "ormolu"))
          (hsPkgs."text" or (errorHandler.buildDepError "text"))
          ] ++ (if compiler.isGhc && (compiler.version).lt "8.10.5"
          then [
            (hsPkgs."ghc-api-compat" or (errorHandler.buildDepError "ghc-api-compat"))
            ]
          else if compiler.isGhc && (compiler.version).eq "8.10.5"
            then [
              (hsPkgs."ghc-api-compat" or (errorHandler.buildDepError "ghc-api-compat"))
              ]
            else if compiler.isGhc && (compiler.version).eq "8.10.6"
              then [
                (hsPkgs."ghc-api-compat" or (errorHandler.buildDepError "ghc-api-compat"))
                ]
              else if compiler.isGhc && (compiler.version).eq "8.10.7"
                then [
                  (hsPkgs."ghc-api-compat" or (errorHandler.buildDepError "ghc-api-compat"))
                  ]
                else (pkgs.lib).optional (compiler.isGhc && (compiler.version).eq "9.0.1") (hsPkgs."ghc-api-compat" or (errorHandler.buildDepError "ghc-api-compat")));
        buildable = true;
        modules = [ "Ide/Plugin/Ormolu" ];
        hsSourceDirs = [ "src" ];
        };
      tests = {
        "tests" = {
          depends = [
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."hls-ormolu-plugin" or (errorHandler.buildDepError "hls-ormolu-plugin"))
            (hsPkgs."hls-test-utils" or (errorHandler.buildDepError "hls-test-utils"))
            (hsPkgs."lsp-types" or (errorHandler.buildDepError "lsp-types"))
            ];
          buildable = true;
          hsSourceDirs = [ "test" ];
          mainPath = [ "Main.hs" ];
          };
        };
      };
    } // rec { src = (pkgs.lib).mkDefault .././plugins/hls-ormolu-plugin; }