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
      specVersion = "1.10";
      identifier = { name = "lsp-types"; version = "1.2.0.0"; };
      license = "MIT";
      copyright = "Alan Zimmerman, 2016-2021";
      maintainer = "alan.zimm@gmail.com";
      author = "Alan Zimmerman";
      homepage = "https://github.com/haskell/lsp";
      url = "";
      synopsis = "Haskell library for the Microsoft Language Server Protocol, data types";
      description = "An implementation of the types to allow language implementors to\nsupport the Language Server Protocol for their specific language.";
      buildType = "Simple";
      isLocal = true;
      detailLevel = "FullDetails";
      licenseFiles = [ "LICENSE" ];
      dataDir = ".";
      dataFiles = [];
      extraSrcFiles = [ "ChangeLog.md" "README.md" ];
      extraTmpFiles = [];
      extraDocFiles = [];
      };
    components = {
      "library" = {
        depends = [
          (hsPkgs."base" or (errorHandler.buildDepError "base"))
          (hsPkgs."aeson" or (errorHandler.buildDepError "aeson"))
          (hsPkgs."binary" or (errorHandler.buildDepError "binary"))
          (hsPkgs."bytestring" or (errorHandler.buildDepError "bytestring"))
          (hsPkgs."containers" or (errorHandler.buildDepError "containers"))
          (hsPkgs."data-default" or (errorHandler.buildDepError "data-default"))
          (hsPkgs."deepseq" or (errorHandler.buildDepError "deepseq"))
          (hsPkgs."directory" or (errorHandler.buildDepError "directory"))
          (hsPkgs."filepath" or (errorHandler.buildDepError "filepath"))
          (hsPkgs."hashable" or (errorHandler.buildDepError "hashable"))
          (hsPkgs."hslogger" or (errorHandler.buildDepError "hslogger"))
          (hsPkgs."lens" or (errorHandler.buildDepError "lens"))
          (hsPkgs."network-uri" or (errorHandler.buildDepError "network-uri"))
          (hsPkgs."rope-utf16-splay" or (errorHandler.buildDepError "rope-utf16-splay"))
          (hsPkgs."scientific" or (errorHandler.buildDepError "scientific"))
          (hsPkgs."some" or (errorHandler.buildDepError "some"))
          (hsPkgs."dependent-sum-template" or (errorHandler.buildDepError "dependent-sum-template"))
          (hsPkgs."dependent-sum" or (errorHandler.buildDepError "dependent-sum"))
          (hsPkgs."text" or (errorHandler.buildDepError "text"))
          (hsPkgs."template-haskell" or (errorHandler.buildDepError "template-haskell"))
          (hsPkgs."temporary" or (errorHandler.buildDepError "temporary"))
          (hsPkgs."unordered-containers" or (errorHandler.buildDepError "unordered-containers"))
          ];
        buildable = true;
        modules = [
          "Language/LSP/Types/CallHierarchy"
          "Language/LSP/Types/Cancellation"
          "Language/LSP/Types/ClientCapabilities"
          "Language/LSP/Types/CodeAction"
          "Language/LSP/Types/CodeLens"
          "Language/LSP/Types/Command"
          "Language/LSP/Types/Common"
          "Language/LSP/Types/Completion"
          "Language/LSP/Types/Configuration"
          "Language/LSP/Types/Declaration"
          "Language/LSP/Types/Definition"
          "Language/LSP/Types/Diagnostic"
          "Language/LSP/Types/DocumentColor"
          "Language/LSP/Types/DocumentFilter"
          "Language/LSP/Types/DocumentHighlight"
          "Language/LSP/Types/DocumentLink"
          "Language/LSP/Types/DocumentSymbol"
          "Language/LSP/Types/FoldingRange"
          "Language/LSP/Types/Formatting"
          "Language/LSP/Types/Hover"
          "Language/LSP/Types/Implementation"
          "Language/LSP/Types/Initialize"
          "Language/LSP/Types/Location"
          "Language/LSP/Types/LspId"
          "Language/LSP/Types/MarkupContent"
          "Language/LSP/Types/Method"
          "Language/LSP/Types/Message"
          "Language/LSP/Types/Parsing"
          "Language/LSP/Types/Progress"
          "Language/LSP/Types/Registration"
          "Language/LSP/Types/References"
          "Language/LSP/Types/Rename"
          "Language/LSP/Types/SelectionRange"
          "Language/LSP/Types/ServerCapabilities"
          "Language/LSP/Types/SignatureHelp"
          "Language/LSP/Types/StaticRegistrationOptions"
          "Language/LSP/Types/TextDocument"
          "Language/LSP/Types/TypeDefinition"
          "Language/LSP/Types/Uri"
          "Language/LSP/Types/Utils"
          "Language/LSP/Types/Window"
          "Language/LSP/Types/WatchedFiles"
          "Language/LSP/Types/WorkspaceEdit"
          "Language/LSP/Types/WorkspaceFolders"
          "Language/LSP/Types/WorkspaceSymbol"
          "Language/LSP/Types"
          "Language/LSP/Types/Capabilities"
          "Language/LSP/Types/Lens"
          "Language/LSP/VFS"
          "Data/IxMap"
          ];
        hsSourceDirs = [ "src" ];
        };
      };
    } // {
    src = (pkgs.lib).mkDefault (pkgs.fetchgit {
      url = "1";
      rev = "minimal";
      sha256 = "";
      }) // {
      url = "1";
      rev = "minimal";
      sha256 = "";
      };
    postUnpack = "sourceRoot+=/lsp-types; echo source root reset to \$sourceRoot";
    }