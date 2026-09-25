{ lib
, stdenv
, fetchFromGitHub
, importNpmLock
, nodejs
}:

let

  version = "unstable-2025-09-25";

  # Upstream pi-skills repository. Each skill lives in its own subdirectory
  # with its own package.json/package-lock.json.
  src = fetchFromGitHub {
    owner = "badlogic";
    repo = "pi-skills";
    rev = "90bb51cae36515a648515b633a81c0c6efc8c74d";
    hash = "sha256-NcaMKdbADZhlnEMTl3pQON9WayBdCjFRHH+dBNOJ+mk=";
  };

  # The node_modules for a skill, built from its package-lock.json.
  #
  # `lockFile` is an optional replacement lockfile for skills that do not
  # vendor one upstream (upstream's is not always committed).
  nodeModulesFor =
    { subdir
    , lockFile ? null
    }:
    importNpmLock.buildNodeModules {
      npmRoot = "${src}/${subdir}";
      packageLock =
        if lockFile != null then
          lib.importJSON lockFile
        else
          lib.importJSON "${src}/${subdir}/package-lock.json";
      inherit nodejs;
    };

  # Build a single skill directory as $out (no nested directory: $out/SKILL.md,
  # $out/transcript.js, etc.), keeping the upstream files verbatim and grafting
  # in a pre-built node_modules/.
  #
  # subdir    - directory name within the upstream repository
  # scripts   - entry points to mark executable and patch shebangs on
  # nodeModules - a derivation containing node_modules/ for this skill
  # patches   - list of { from, to } string replacements applied to SKILL.md
  mkSkill =
    { subdir
    , scripts ? [ ]
    , nodeModules ? null
    , patches ? [ ]
    }:
    stdenv.mkDerivation {
      name = "pi-skill-${subdir}-${version}";

      inherit src;
      sourceRoot = "${src.name}/${subdir}";

      # nodejs is needed by patchShebangs; the scripts use `#!/usr/bin/env node`.
      nativeBuildInputs = [ nodejs ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r ./. $out/

        # Drop build-only metadata that is not needed at runtime.
        rm -rf $out/node_modules $out/default.nix \
               $out/.gitignore $out/package-lock.json

        ${lib.optionalString (scripts != [ ]) ''
          patchShebangs ${lib.concatMapStringsSep " " (s: "$out/${s}") scripts}
          chmod +x ${lib.concatMapStringsSep " " (s: "$out/${s}") scripts}
        ''}

        ${lib.optionalString (nodeModules != null) ''
          ln -s ${nodeModules}/node_modules $out/node_modules
        ''}

        ${lib.concatMapStringsSep "\n" (p: ''
          substituteInPlace $out/SKILL.md \
            --replace-fail ${lib.escapeShellArg p.from} ${lib.escapeShellArg p.to}
        '') patches}

        runHook postInstall
      '';

      meta = {
        description = "badlogic's pi-skills: ${subdir}";
        homepage = "https://github.com/badlogic/pi-skills";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
      };
    };

  # Upstream's setup steps tell the agent to run `npm install` in {baseDir}.
  # That cannot work in the read-only store, so they are replaced by a note
  # that the built dependencies are already present.
  no-install = "The scripts are pre-built and self-contained; no installation step is required.";

in
{

  brave-search = mkSkill {
    subdir = "brave-search";
    scripts = [ "search.js" "content.js" ];
    nodeModules = nodeModulesFor { subdir = "brave-search"; };
    patches = [{
      from = "5. Install dependencies (run once):\n   ```bash\n   cd {baseDir}\n   npm install\n   ```";
      to = "5. ${no-install}";
    }];
  };

  youtube-transcript = mkSkill {
    subdir = "youtube-transcript";
    scripts = [ "transcript.js" ];
    nodeModules = nodeModulesFor {
      subdir = "youtube-transcript";
      # Upstream does not commit a package-lock.json for this skill; use the
      # vendored one so the dependency set is pinned.
      lockFile = ./youtube-transcript-package-lock.json;
    };
    patches = [{
      from = "```bash\ncd {baseDir}\nnpm install\n```";
      to = no-install;
    }];
  };

}
