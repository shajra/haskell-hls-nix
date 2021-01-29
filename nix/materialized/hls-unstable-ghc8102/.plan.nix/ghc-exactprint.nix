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
    flags = { roundtrip = false; dev = false; };
    package = {
      specVersion = "1.10";
      identifier = { name = "ghc-exactprint"; version = "0.6.3.3"; };
      license = "BSD-3-Clause";
      copyright = "";
      maintainer = "alan.zimm@gmail.com";
      author = "Alan Zimmerman, Matthew Pickering";
      homepage = "";
      url = "";
      synopsis = "ExactPrint for GHC";
      description = "Using the API Annotations available from GHC 7.10.2, this\nlibrary provides a means to round trip any code that can\nbe compiled by GHC, currently excluding lhs files.\n\nIt does this with a phased approach\n\n* Delta - converts GHC API Annotations into relative\noffsets, indexed by SrcSpan\n\n* Transform - functions to facilitate changes to\nthe AST, adjusting the annotations generated in the\nDelta phase to suit the changes.\n\n* Print - converts an AST and its annotations to\nproperly formatted source text.\n\n* Pretty - adds annotations to an AST (fragment) so that\nthe output can be parsed back to the same AST.\n\n\nNote: requires GHC 7.10.2 or later";
      buildType = "Simple";
      isLocal = true;
      detailLevel = "FullDetails";
      licenseFiles = [ "LICENSE" ];
      dataDir = "";
      dataFiles = [];
      extraSrcFiles = [
        "ChangeLog"
        "src-ghc710/Language/Haskell/GHC/ExactPrint/*.hs"
        "tests/examples/failing/*.hs"
        "tests/examples/ghc710-only/*.hs"
        "tests/examples/ghc710/*.hs"
        "tests/examples/ghc80/*.hs"
        "tests/examples/ghc810/*.hs"
        "tests/examples/ghc82/*.hs"
        "tests/examples/ghc84/*.hs"
        "tests/examples/ghc86/*.hs"
        "tests/examples/ghc88/*.hs"
        "tests/examples/pre-ghc810/*.hs"
        "tests/examples/pre-ghc86/*.hs"
        "tests/examples/vect/*.hs"
        "tests/examples/transform/*.hs"
        "tests/examples/failing/*.hs.bad"
        "tests/examples/transform/*.hs.expected"
        "tests/examples/ghc710/*.hs-boot"
        ];
      extraTmpFiles = [];
      extraDocFiles = [];
      };
    components = {
      "library" = {
        depends = ([
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
          (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
          (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
          (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
          (hsPkgs."ghc-paths" or (errorHandler.buildDepError "ghc-paths"))
          (hsPkgs."mtl" or (errorHandler.buildDepError "mtl"))
          (hsPkgs."syb" or (errorHandler.buildDepError "syb"))
          (hsPkgs."free" or (errorHandler.buildDepError "free"))
          ] ++ (pkgs.lib).optional (!(compiler.isGhc && (compiler.version).ge "8.0")) (hsPkgs."fail" or (errorHandler.buildDepError "fail"))) ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") (hsPkgs."ghc-boot" or (errorHandler.buildDepError "ghc-boot"));
        buildable = if compiler.isGhc && (compiler.version).lt "7.10.2"
          then false
          else true;
        modules = [
          "Language/Haskell/GHC/ExactPrint"
          "Language/Haskell/GHC/ExactPrint/Annotate"
          "Language/Haskell/GHC/ExactPrint/AnnotateTypes"
          "Language/Haskell/GHC/ExactPrint/Annotater"
          "Language/Haskell/GHC/ExactPrint/Delta"
          "Language/Haskell/GHC/ExactPrint/Lookup"
          "Language/Haskell/GHC/ExactPrint/Parsers"
          "Language/Haskell/GHC/ExactPrint/Preprocess"
          "Language/Haskell/GHC/ExactPrint/Pretty"
          "Language/Haskell/GHC/ExactPrint/Print"
          "Language/Haskell/GHC/ExactPrint/Transform"
          "Language/Haskell/GHC/ExactPrint/Types"
          "Language/Haskell/GHC/ExactPrint/Utils"
          ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).le "8.0.2") "Language/Haskell/GHC/ExactPrint/GhcInterim";
        hsSourceDirs = [
          "src"
          ] ++ (if compiler.isGhc && (compiler.version).gt "8.8.4"
          then [ "src-ghc810" ]
          else if compiler.isGhc && (compiler.version).gt "8.6.5"
            then [ "src-ghc88" ]
            else if compiler.isGhc && (compiler.version).gt "8.4.4"
              then [ "src-ghc86" ]
              else if compiler.isGhc && (compiler.version).gt "8.2.2"
                then [ "src-ghc84" ]
                else if compiler.isGhc && (compiler.version).gt "8.0.3"
                  then [ "src-ghc82" ]
                  else if compiler.isGhc && (compiler.version).gt "7.10.3"
                    then [ "src-ghc80" ]
                    else [ "src-ghc710" ]);
        };
      exes = {
        "roundtrip" = {
          depends = (pkgs.lib).optionals (compiler.isGhc && (compiler.version).ge "7.10.2" && flags.roundtrip) ([
            (hsPkgs."HUnit" or (errorHandler.buildDepError "HUnit"))
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filemanip" or (errorHandler.buildDepError "filemanip"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."ghc-exactprint" or (errorHandler.buildDepError "ghc-exactprint"))
            (hsPkgs."ghc-paths" or (errorHandler.buildDepError "ghc-paths"))
            (hsPkgs."syb" or (errorHandler.buildDepError "syb"))
            (hsPkgs."temporary" or (errorHandler.buildDepError "temporary"))
            (hsPkgs."time" or (errorHandler.buildDepError "time"))
            ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") (hsPkgs."ghc-boot" or (errorHandler.buildDepError "ghc-boot")));
          buildable = if compiler.isGhc && (compiler.version).ge "7.10.2" && flags.roundtrip
            then true
            else false;
          modules = [ "Test/Common" "Test/CommonUtils" "Test/Consistency" ];
          hsSourceDirs = [ "tests" ];
          mainPath = ([
            "Roundtrip.hs"
            ] ++ (if compiler.isGhc && (compiler.version).ge "7.10.2" && flags.roundtrip
            then [
              ""
              ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") ""
            else [ "" ])) ++ [ "" ];
          };
        "static" = {
          depends = (pkgs.lib).optionals (flags.roundtrip) ([
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filemanip" or (errorHandler.buildDepError "filemanip"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."Diff" or (errorHandler.buildDepError "Diff"))
            ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") (hsPkgs."ghc-boot" or (errorHandler.buildDepError "ghc-boot")));
          buildable = if flags.roundtrip then true else false;
          hsSourceDirs = [ "tests" ];
          mainPath = ([ "Static.hs" ] ++ (if flags.roundtrip
            then [
              ""
              ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") ""
            else [ "" ])) ++ [ "" ];
          };
        "prepare-hackage" = {
          depends = (pkgs.lib).optionals (flags.roundtrip) ([
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filemanip" or (errorHandler.buildDepError "filemanip"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."ghc-paths" or (errorHandler.buildDepError "ghc-paths"))
            (hsPkgs."HUnit" or (errorHandler.buildDepError "HUnit"))
            (hsPkgs."text" or (errorHandler.buildDepError "text"))
            (hsPkgs."turtle" or (errorHandler.buildDepError "turtle"))
            ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") (hsPkgs."ghc-boot" or (errorHandler.buildDepError "ghc-boot")));
          buildable = if flags.roundtrip then true else false;
          hsSourceDirs = [ "tests" ];
          mainPath = ([ "PrepareHackage.hs" ] ++ (if flags.roundtrip
            then [
              ""
              ] ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") ""
            else [ "" ])) ++ [ "" ];
          };
        };
      tests = {
        "test" = {
          depends = (([
            (hsPkgs."HUnit" or (errorHandler.buildDepError "HUnit"))
            (hsPkgs."base" or (errorHandler.buildDepError "base"))
            (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
            (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
            (hsPkgs."Diff" or (errorHandler.buildDepError "Diff"))
            (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
            (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
            (hsPkgs."ghc" or (errorHandler.buildDepError "ghc"))
            (hsPkgs."ghc-paths" or (errorHandler.buildDepError "ghc-paths"))
            (hsPkgs."mtl" or (errorHandler.buildDepError "mtl"))
            (hsPkgs."syb" or (errorHandler.buildDepError "syb"))
            (hsPkgs."silently" or (errorHandler.buildDepError "silently"))
            (hsPkgs."filemanip" or (errorHandler.buildDepError "filemanip"))
            ] ++ (pkgs.lib).optional (!(compiler.isGhc && (compiler.version).ge "8.0")) (hsPkgs."fail" or (errorHandler.buildDepError "fail"))) ++ (if flags.dev
            then [ (hsPkgs."free" or (errorHandler.buildDepError "free")) ]
            else [
              (hsPkgs."ghc-exactprint" or (errorHandler.buildDepError "ghc-exactprint"))
              ])) ++ (pkgs.lib).optional (compiler.isGhc && (compiler.version).ge "7.11") (hsPkgs."ghc-boot" or (errorHandler.buildDepError "ghc-boot"));
          buildable = if compiler.isGhc && (compiler.version).lt "7.10.2"
            then false
            else true;
          modules = [
            "Test/Common"
            "Test/CommonUtils"
            "Test/Consistency"
            "Test/NoAnnotations"
            "Test/Transform"
            ];
          hsSourceDirs = (if flags.dev
            then [ "tests" "src" ]
            else [
              "tests"
              ]) ++ (if compiler.isGhc && (compiler.version).gt "8.8.4"
            then [ "src-ghc810" ]
            else if compiler.isGhc && (compiler.version).gt "8.6.5"
              then [ "src-ghc88" ]
              else if compiler.isGhc && (compiler.version).gt "8.4.4"
                then [ "src-ghc86" ]
                else if compiler.isGhc && (compiler.version).gt "8.2.2"
                  then [ "src-ghc84" ]
                  else if compiler.isGhc && (compiler.version).gt "8.0.3"
                    then [ "src-ghc82" ]
                    else if compiler.isGhc && (compiler.version).gt "7.10.3"
                      then [ "src-ghc80" ]
                      else [ "src-ghc710" ]);
          mainPath = [ "Test.hs" ];
          };
        };
      };
    } // rec { src = (pkgs.lib).mkDefault .././.source-repository-packages/0; }