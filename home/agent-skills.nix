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

  skillFiles = lib.listToAttrs (
    lib.concatMap (skill: map (mkSkillFile skill) (skillAgents skill)) cfg.skills
  );

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
        }
      );
      default = {
        codex.targetDir = ".codex/skills";
        gemini.targetDir = ".gemini/skills";
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
    home.file = skillFiles;
  };
}
