{ config, lib, ... }:
let
  cfg = config.agentSkills;

  configuredAgents = builtins.attrNames cfg.agents;

  skillAgents =
    skill:
    if skill.agents == [ ] then configuredAgents else skill.agents;

  mkSkillFile =
    skill: agentName:
    lib.nameValuePair "${cfg.agents.${agentName}.targetDir}/${skill.name}" {
      source = skill.source;
      recursive = true;
    };

  symlinkSkillFiles = lib.listToAttrs (
    lib.concatMap (
      skill:
      map (mkSkillFile skill) (
        lib.filter (agentName: cfg.agents.${agentName}.installMethod == "symlink") (skillAgents skill)
      )
    ) cfg.skills
  );

  copiedSkillInstalls = lib.concatMap (
    skill:
    map (
      agentName:
      let
        agentCfg = cfg.agents.${agentName};
        targetDir = "${config.home.homeDirectory}/${agentCfg.targetDir}/${skill.name}";
        sourceDir = "${toString skill.source}/.";
      in
      ''
        run rm -rf ${lib.escapeShellArg targetDir}
        run mkdir -p ${lib.escapeShellArg targetDir}
        run cp -R --no-preserve=mode,ownership ${lib.escapeShellArg sourceDir} ${lib.escapeShellArg targetDir}
      ''
    ) (lib.filter (agentName: cfg.agents.${agentName}.installMethod == "copy") (skillAgents skill))
  ) cfg.skills;

  skillAssertions = lib.concatMap (
    skill:
    map (agentName: {
      assertion = builtins.hasAttr agentName cfg.agents;
      message = "agentSkills skill '${skill.name}' references unknown agent '${agentName}'.";
    }) (skillAgents skill)
  ) cfg.skills;
in
{
  options.agentSkills = {
    enable = lib.mkEnableOption "declarative AI skill installation";

    agents = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.targetDir = lib.mkOption {
            type = lib.types.str;
            description = "Home-relative directory where the agent loads installed skills.";
          };

          options.installMethod = lib.mkOption {
            type = lib.types.enum [
              "symlink"
              "copy"
            ];
            default = "symlink";
            description = "How Home Manager should materialize the skill for this agent.";
          };
        }
      );
      default = {
        codex = {
          targetDir = ".codex/skills";
          installMethod = "copy";
        };
        gemini = {
          targetDir = ".gemini/skills";
          installMethod = "symlink";
        };
      };
      description = "Known agents and the directories they read skills from.";
    };

    skills = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Directory name to install the skill as.";
            };

            source = lib.mkOption {
              type = lib.types.path;
              description = "Source directory that contains the skill files, including SKILL.md.";
            };

            agents = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Agents that should receive this skill. Empty means all configured agents.";
            };
          };
        }
      );
      default = [ ];
      description = "Declarative skills to install into one or more agent-specific skill directories.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = skillAssertions;
    home.file = symlinkSkillFiles;

    home.activation.agentSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.concatStringsSep "\n" copiedSkillInstalls
    );
  };
}
