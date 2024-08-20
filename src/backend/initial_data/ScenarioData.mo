import Scenario "../models/Scenario";
module {
    public let scenarios : [Scenario.ScenarioMetaData] = [
        {
            id = "corrupted_treant";
            title = "Corrupted Treant";
            description = "A massive, twisted tree creature blocks your path. Dark energy pulses through its bark.";
            data = [];
            icon = [
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47)],
                [(85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47), (85, 107, 47)],
            ];
            choices = [

                {
                    id = "attack";
                    description = "Engage the corrupted treant in combat.";
                    requirement = null;
                    pathId = "attack_treant";
                },
                {
                    id = "purify";
                    description = "Attempt to cleanse the corruption using magic.";
                    requirement = ? #stat((#magic, 2));
                    pathId = "purify_treant";
                },
                {
                    id = "evade";
                    description = "Try to find a way around the treant without confrontation.";
                    requirement = null;
                    pathId = "evade_treant";
                },
                {
                    id = "communicate";
                    description = "Use your ability to speak with nature to reason with the treant.";
                    requirement = ? #trait("naturalist");
                    pathId = "communicate_treant";
                },
            ];
            undecidedPathId = "frozen";
            paths = [
                {
                    id = "attack_treant";
                    description = "You attack the treant.";
                    effects = [];
                    paths = [
                        {
                            weight = 0.7;
                            condition = null;
                            pathId = "victory";
                        },
                        {
                            weight = 0.3;
                            condition = null;
                            pathId = "victory_with_injury";
                        },
                    ];
                },
                {
                    id = "victory";
                    description = "You defeat the treant";
                    effects = [#addItem(#raw("treant_bark"))];
                    paths = [];
                },
                {
                    id = "victory_with_injury";
                    description = "The treant hits you.";
                    effects = [#damage(#random(1, 3))];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "victory";
                    }];
                },
                {
                    id = "purify_treant";
                    description = "You channel magical energy to purify the treant.";
                    effects = [];
                    paths = [
                        {
                            weight = 0.8;
                            condition = null;
                            pathId = "successful_purification";
                        },
                        {
                            weight = 0.2;
                            condition = null;
                            pathId = "failed_purification";
                        },
                    ];
                },
                {
                    id = "successful_purification";
                    description = "Your magic cleanses the corruption. The treant returns to its peaceful state.";
                    effects = [#reward, #addTrait(#raw("naturalist"))];
                    paths = [];
                },
                {
                    id = "failed_purification";
                    description = "The corruption resists your magic and lashes out!";
                    effects = [#damage(#random(1, 3))];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "attack_treant";
                    }];
                },
                {
                    id = "evade_treant";
                    description = "You attempt to sneak past the treant.";
                    effects = [];
                    paths = [
                        {
                            weight = 0.7;
                            condition = null;
                            pathId = "successful_evasion";
                        },
                        {
                            weight = 0.3;
                            condition = null;
                            pathId = "failed_evasion";
                        },
                    ];
                },
                {
                    id = "successful_evasion";
                    description = "You successfully navigate around the treant without incident.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "failed_evasion";
                    description = "The treant notices your attempt to sneak by and attacks!";
                    effects = [#damage(#random(1, 3))];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "attack_treant";
                    }];
                },
                {
                    id = "communicate_treant";
                    description = "You attempt to communicate with the treant using your nature-speaking abilities.";
                    effects = [];
                    paths = [
                        {
                            weight = 0.9;
                            condition = null;
                            pathId = "successful_communication";
                        },
                        {
                            weight = 0.1;
                            condition = null;
                            pathId = "failed_communication";
                        },
                    ];
                },
                {
                    id = "successful_communication";
                    description = "You reach the treant's consciousness. It calms and allows you to pass.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "failed_communication";
                    description = "The corruption is too strong. The treant attacks despite your efforts.";
                    effects = [#damage(#random(1, 3))];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "attack_treant";
                    }];
                },
                {
                    id = "frozen";
                    description = "You stand frozen, unable to decide. The treant attacks.";
                    effects = [#damage(#random(1, 3))];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "attack_treant";
                    }];
                },
            ];
        },
        {
            id = "dark_elf_ambush";
            title = "Dark Elf Ambush";
            description = "A group of dark elves emerges from the shadows, weapons drawn. Their eyes gleam with malicious intent.";
            icon = [
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (255, 255, 255), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (255, 255, 255), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (255, 255, 255), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (255, 255, 255), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (255, 255, 255), (128, 0, 128), (128, 0, 128), (255, 255, 255), (128, 0, 128), (128, 0, 128), (255, 255, 255), (128, 0, 128), (128, 0, 128), (255, 255, 255), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (255, 255, 255), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (255, 255, 255), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (255, 255, 255), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (255, 255, 255), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (255, 255, 255), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (255, 255, 255), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (255, 255, 255), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (128, 0, 128), (255, 255, 255), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
                [(0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0)],
            ];
            data = [];
            choices = [
                {
                    id = "fight";
                    description = "Stand your ground and engage the dark elves in combat.";
                    requirement = null;
                    pathId = "fight_elves";
                },
                {
                    id = "negotiate";
                    description = "Attempt to parley with the dark elves, offering something in exchange for safe passage.";
                    requirement = null;
                    pathId = "negotiate_elves";
                },
                {
                    id = "retreat";
                    description = "Try to escape from the ambush, potentially leaving behind some resources.";
                    requirement = null;
                    pathId = "retreat_from_elves";
                },
                {
                    id = "stealth";
                    description = "Use your agility to sneak past the dark elves without being detected.";
                    requirement = ? #trait("agile");
                    pathId = "stealth_past_elves";
                },
            ];
            undecidedPathId = "frozen";
            paths = [
                {
                    id = "fight_elves";
                    description = "You stand your ground against the dark elves.";
                    effects = [];
                    paths = [
                        {
                            weight = 0.6;
                            condition = null;
                            pathId = "successful_fight";
                        },
                        {
                            weight = 0.4;
                            condition = null;
                            pathId = "elf_attack";
                        },
                    ];
                },
                {
                    id = "successful_fight";
                    description = "You successfully fend off the dark elves!";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "negotiate_elves";
                    description = "You attempt to negotiate with the dark elves.";
                    effects = [#removeItem(#random)];
                    paths = [
                        {
                            weight = 0.5;
                            condition = null;
                            pathId = "successful_negotiation";
                        },
                        {
                            weight = 0.5;
                            condition = null;
                            pathId = "failed_negotiation";
                        },
                    ];
                },
                {
                    id = "successful_negotiation";
                    description = "The dark elves accept your offer and let you pass.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "failed_negotiation";
                    description = "Negotiations fail, and the dark elves attack!";
                    effects = [];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "elf_attack";
                    }];
                },
                {
                    id = "retreat_from_elves";
                    description = "You attempt to retreat from the dark elves.";
                    effects = [];
                    paths = [
                        {
                            weight = 0.67;
                            condition = null;
                            pathId = "successful_retreat";
                        },
                        {
                            weight = 0.33;
                            condition = null;
                            pathId = "failed_retreat";
                        },
                    ];
                },
                {
                    id = "successful_retreat";
                    description = "You manage to escape.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "failed_retreat";
                    description = "Your retreat fails, and the dark elves catch up to you.";
                    effects = [];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "elf_attack";
                    }];
                },
                {
                    id = "stealth_past_elves";
                    description = "You attempt to sneak past the dark elves.";
                    effects = [];
                    paths = [
                        {
                            weight = 0.8;
                            condition = null;
                            pathId = "successful_stealth";
                        },
                        {
                            weight = 0.2;
                            condition = null;
                            pathId = "failed_stealth";
                        },
                    ];
                },
                {
                    id = "successful_stealth";
                    description = "You successfully sneak past the dark elves without being detected.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "failed_stealth";
                    description = "Despite your agility, the dark elves spot you.";
                    effects = [];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "elf_attack";
                    }];
                },
                {
                    id = "elf_attack";
                    description = "The dark elves attack!";
                    effects = [#damage(#random(1, 3))];
                    paths = [];
                },
                {
                    id = "frozen";
                    description = "You stand frozen, unable to decide. The elves attack.";
                    effects = [];
                    paths = [{
                        weight = 1;
                        condition = null;
                        pathId = "elf_attack";
                    }];
                },
            ];
        },
        {
            id = "druidic_sanctuary";
            title = "Druidic Sanctuary";
            description = "You enter a serene grove where druids commune with nature. The trees seem to be whispering gossip.";
            icon = [
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34)],
                [(34, 139, 34), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (34, 139, 34)],
                [(34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34)],
                [(34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34)],
                [(34, 139, 34), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (34, 139, 34)],
                [(34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (173, 255, 47), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
            ];
            data = [
                {
                    id = "healing_cost";
                    name = "Healing Cost";
                    value = #nat({ min = 15; max = 25 });
                },
                {
                    id = "blessing_cost";
                    name = "Blessing Cost";
                    value = #nat({ min = 20; max = 30 });
                },
                {
                    id = "commune_cost";
                    name = "Commune Cost";
                    value = #nat({ min = 10; max = 20 });
                },
            ];
            choices = [
                {
                    id = "seek_healing";
                    description = "Seek healing from the druids. Side effects may include turning into a tree.";
                    pathId = "seek_healing_path";
                    requirement = null;
                },
                {
                    id = "request_blessing";
                    description = "Request a druidic blessing. Warning: May attract squirrels.";
                    pathId = "request_blessing_path";
                    requirement = null;
                },
                {
                    id = "commune_with_nature";
                    description = "Commune with nature. Hope you speak fluent squirrel.";
                    pathId = "commune_with_nature_path";
                    requirement = ? #trait("naturalist");
                },
                {
                    id = "leave";
                    description = "Leave the sanctuary. The pollen was getting to you anyway.";
                    pathId = "leave_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "seek_healing_path";
                    description = "The druids surround you, chanting in what sounds suspiciously like plant-ese.";
                    effects = [
                        #removeGold(#dataField("healing_cost")),
                        #heal(#random(3, 7)),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("healing_cost"));
                            pathId = "healing_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "healing_failure";
                        },
                    ];
                },
                {
                    id = "healing_success";
                    description = "You feel rejuvenated, and slightly more photosynthetic.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "healing_failure";
                    description = "The druids frown at your empty pockets. Seems Mother Nature doesn't work pro bono.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "request_blessing_path";
                    description = "The druids prepare to bestow a blessing upon you.";
                    effects = [
                        #removeGold(#dataField("blessing_cost")),
                    ];
                    paths = [
                        {
                            weight = 2;
                            condition = ? #hasGold(#dataField("blessing_cost"));
                            pathId = "blessing_success";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("blessing_cost"));
                            pathId = "blessing_partial";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "blessing_failure";
                        },
                    ];
                },
                {
                    id = "blessing_success";
                    description = "The druids bless you with the 'strength of oak'. You feel sturdier, and vaguely like you want to grow leaves.";
                    effects = [#upgradeStat(#defense, #raw(1))];
                    paths = [];
                },
                {
                    id = "blessing_partial";
                    description = "The blessing goes slightly awry. You now have an inexplicable craving for sunlight and water.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "blessing_failure";
                    description = "The druids shake their heads. Apparently, 'the blessing of poverty' isn't a thing.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "commune_with_nature_path";
                    description = "You attempt to commune with nature.";
                    effects = [
                        #removeGold(#dataField("commune_cost")),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("commune_cost"));
                            pathId = "commune_success";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("commune_cost"));
                            pathId = "commune_partial";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "commune_failure";
                        },
                    ];
                },
                {
                    id = "commune_success";
                    description = "You successfully commune with nature. A squirrel imparts ancient wisdom, and hands you a nut... er, herb.";
                    effects = [#addItem(#raw("herbs"))];
                    paths = [];
                },
                {
                    id = "commune_partial";
                    description = "Your attempt at communing results in a lengthy conversation with a sassy fern. You're not sure, but you think it just insulted your haircut.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "commune_failure";
                    description = "Nature, it seems, doesn't accept I.O.U.s. The trees rustle disapprovingly at your lack of funds.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "leave_path";
                    description = "You leave the sanctuary, shaking off a few clingy vines. You could swear that oak just waved goodbye.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand motionless, unsure if that bush just winked at you.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "dwarven_weaponsmith";
            title = "Dwarven Weaponsmith";
            description = "You encounter a surly dwarven weaponsmith, offering attack upgrades at steep prices.";
            icon = [
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (0, 0, 0), (210, 180, 140), (210, 180, 140), (0, 0, 0), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (192, 192, 192), (192, 192, 192), (192, 192, 192), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (192, 192, 192), (192, 192, 192), (192, 192, 192), (192, 192, 192), (192, 192, 192), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (165, 42, 42), (165, 42, 42), (165, 42, 42), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
                [(139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19)],
            ];
            data = [
                {
                    id = "upgrade_cost";
                    name = "Upgrade Cost";
                    value = #nat({ min = 20; max = 40 });
                },
                {
                    id = "discounted_cost";
                    name = "Discounted Cost";
                    value = #nat({ min = 30; max = 50 });
                },
                {
                    id = "special_deal";
                    name = "Special Deal Cost";
                    value = #nat({ min = 25; max = 40 });
                },
            ];
            choices = [
                {
                    id = "upgrade_attack";
                    description = "Upgrade your attack (+1).";
                    pathId = "upgrade_attack_path";
                    requirement = null;
                },
                {
                    id = "haggle";
                    description = "Attempt to haggle for a better price.";
                    pathId = "haggle_path";
                    requirement = null;
                },
                {
                    id = "leave";
                    description = "Leave without upgrading.";
                    pathId = "leave_path";
                    requirement = null;
                },
                {
                    id = "dwarf_negotiate";
                    description = "Have your dwarf crew member negotiate.";
                    pathId = "dwarf_negotiate_path";
                    requirement = ? #race("dwarf");
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "upgrade_attack_path";
                    description = "You attempt to upgrade your attack.";
                    effects = [
                        #removeGold(#dataField("upgrade_cost")),
                        #upgradeStat(#attack, #raw(1)),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("upgrade_cost"));
                            pathId = "upgrade_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "upgrade_failure";
                        },
                    ];
                },
                {
                    id = "upgrade_success";
                    description = "You upgrade your attack by 1 for {upgrade_cost} gold.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "upgrade_failure";
                    description = "You don't have enough gold to upgrade your attack.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "haggle_path";
                    description = "You attempt to haggle with the dwarf.";
                    effects = [];
                    paths = [
                        {
                            weight = 3;
                            condition = null;
                            pathId = "haggle_success";
                        },
                        {
                            weight = 7;
                            condition = null;
                            pathId = "haggle_failure";
                        },
                    ];
                },
                {
                    id = "haggle_success";
                    description = "The dwarf grudgingly offers a discounted upgrade price of {discounted_cost} gold.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "haggle_failure";
                    description = "The dwarf is offended by your haggling and refuses to upgrade your attack.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "dwarf_negotiate_path";
                    description = "Your dwarf crew member negotiates a special deal: {special_deal} gold for a weapon upgrade.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "leave_path";
                    description = "You leave the weaponsmith's shop without upgrading your attack.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand frozen, unable to decide. The dwarf pushes you out of his shop.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "enchanted_grove";
            title = "Enchanted Grove";
            description = "You enter a serene grove with magical properties.";
            icon = [
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (255, 215, 0), (255, 215, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (255, 215, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 255, 0), (0, 255, 0), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
            ];
            data = [
                {
                    id = "meditation_cost";
                    name = "Meditation Cost";
                    value = #nat({ min = 5; max = 10 });
                },
                {
                    id = "harvest_cost";
                    name = "Harvest Cost";
                    value = #nat({ min = 1; max = 3 });
                },
                {
                    id = "commune_cost";
                    name = "Commune Cost";
                    value = #nat({ min = 10; max = 20 });
                },
            ];
            choices = [
                {
                    id = "meditate";
                    description = "Meditate to increase your magic stat.";
                    pathId = "meditate_path";
                    requirement = null;
                },
                {
                    id = "harvest";
                    description = "Harvest rare herbs (costs health).";
                    pathId = "harvest_path";
                    requirement = ? #trait("naturalist");
                },
                {
                    id = "commune";
                    description = "Commune with nature spirits for a chance at a unique item.";
                    pathId = "commune_path";
                    requirement = null;
                },
                {
                    id = "leave";
                    description = "Leave the grove.";
                    pathId = "leave_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "meditate_path";
                    description = "You attempt to meditate in the grove.";
                    effects = [
                        #removeGold(#dataField("meditation_cost")),
                        #upgradeStat(#magic, #raw(1)),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("meditation_cost"));
                            pathId = "meditate_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "meditate_failure";
                        },
                    ];
                },
                {
                    id = "meditate_success";
                    description = "You meditate and feel your magical abilities grow stronger.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "meditate_failure";
                    description = "You don't have enough gold to perform the meditation ritual.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "harvest_path";
                    description = "You attempt to harvest rare herbs from the grove.";
                    effects = [
                        #damage(#dataField("harvest_cost")),
                        #addItem(#raw("herbs")),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "harvest_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "harvest_rejuvenation";
                        },
                    ];
                },
                {
                    id = "harvest_success";
                    description = "You harvest rare herbs from the grove, expending some energy in the process.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "harvest_rejuvenation";
                    description = "The grove's magic rejuvenates you slightly.";
                    effects = [
                        #heal(#raw(1)), // Simplified from data.harvestCost / 2
                    ];
                    paths = [];
                },
                {
                    id = "commune_path";
                    description = "You attempt to commune with nature spirits.";
                    effects = [
                        #removeGold(#dataField("commune_cost")),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("commune_cost"));
                            pathId = "commune_success";
                        },
                        {
                            weight = 2;
                            condition = ? #hasGold(#dataField("commune_cost"));
                            pathId = "commune_failure";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "commune_no_gold";
                        },
                    ];
                },
                {
                    id = "commune_success";
                    description = "You commune with nature spirits and receive a unique item.";
                    effects = [
                        #addItem(#raw("crystal")),
                    ];
                    paths = [];
                },
                {
                    id = "commune_failure";
                    description = "You commune with nature spirits but receive no tangible reward.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "commune_no_gold";
                    description = "You don't have enough gold to commune with nature spirits.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "leave_path";
                    description = "You leave the enchanted grove, feeling refreshed.";
                    effects = [
                        #heal(#raw(1)),
                    ];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand in awe of the grove's beauty, unable to decide what to do.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "fairy_market";
            title = "Fairy Market";
            description = "You stumble upon a hidden fairy market, offering magical trinkets and mysterious trades.";
            icon = [
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (255, 192, 203), (255, 192, 203), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (255, 215, 0), (255, 215, 0), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (255, 192, 203), (255, 192, 203), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (255, 215, 0), (255, 215, 0), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (222, 184, 135), (222, 184, 135), (0, 0, 0), (222, 184, 135), (222, 184, 135), (0, 0, 0), (222, 184, 135), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (222, 184, 135), (222, 184, 135), (255, 0, 0), (222, 184, 135), (222, 184, 135), (0, 0, 255), (222, 184, 135), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
                [(143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143), (143, 188, 143)],
            ];
            data = [
                {
                    id = "trinket_cost";
                    name = "Trinket Cost";
                    value = #nat({ min = 20; max = 40 });
                },
                {
                    id = "trinket_item";
                    name = "Trinket Item";
                    value = #text({
                        options = [
                            ("herbs", 0.9),
                            ("echo_crystal", 0.1),
                        ];
                    });
                },
            ];
            choices = [
                {
                    id = "buy_trinket";
                    description = "Purchase a magical trinket.";
                    pathId = "buy_trinket_path";
                    requirement = null;
                },
                {
                    id = "trade";
                    description = "Trade an item for fairy magic.";
                    pathId = "trade_path";
                    requirement = null;
                },
                {
                    id = "leave";
                    description = "Leave the market.";
                    pathId = "leave_path";
                    requirement = null;
                },
                {
                    id = "use_crystal";
                    description = "Use a  to get better deals.";
                    pathId = "use_crystal_path";
                    requirement = ? #item("crystal");
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "buy_trinket_path";
                    description = "You attempt to purchase a magical trinket.";
                    effects = [
                        #removeGold(#dataField("trinket_cost")),
                        #addItem(#dataField("trinket_item")),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("trinket_cost"));
                            pathId = "trinket_purchase_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "trinket_purchase_failure";
                        },
                    ];
                },
                {
                    id = "trinket_purchase_success";
                    description = "You purchase a mysterious trinket for {trinket_cost} gold.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "trinket_purchase_failure";
                    description = "You don't have enough gold to buy a trinket.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "trade_path";
                    description = "You offer to trade an item for fairy magic.";
                    effects = [
                        #removeItem(#random),
                        #upgradeStat(#magic, #raw(1)),
                    ];
                    paths = [
                        {
                            weight = 3;
                            condition = null;
                            pathId = "trade_success";
                        },
                        {
                            weight = 2;
                            condition = null;
                            pathId = "trade_failure";
                        },
                    ];
                },
                {
                    id = "trade_success";
                    description = "The fairies accept your trade, granting you a magical boon.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "trade_failure";
                    description = "The fairies reject your offer, seeming offended.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "use_crystal_path";
                    description = "Your fairy charm glows, granting you favor in the market.";
                    effects = [
                        #removeItem(#specific(#raw("crystal"))),
                        #upgradeStat(#magic, #raw(1)),
                    ];
                    paths = [];
                },
                {
                    id = "leave_path";
                    description = "You leave the fairy market, the magical stalls fading behind you.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand frozen, unable to decide. The faeries escort you out of the market.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "goblin_raiding_party";
            title = "Goblin Raiding Party";
            description = "A band of goblins emerges from the underbrush, brandishing crude weapons and eyeing your possessions.";
            icon = [
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 255, 0), (0, 255, 0), (0, 100, 0), (0, 100, 0), (0, 255, 0), (0, 255, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 255, 0), (0, 0, 0), (0, 255, 0), (0, 255, 0), (0, 255, 0), (0, 0, 0), (0, 255, 0), (0, 255, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 255, 0), (0, 255, 0), (0, 255, 0), (0, 255, 0), (0, 255, 0), (0, 255, 0), (0, 255, 0), (0, 255, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 255, 0), (0, 255, 0), (139, 69, 19), (0, 255, 0), (0, 255, 0), (139, 69, 19), (0, 255, 0), (0, 255, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 255, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 255, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (139, 69, 19), (139, 69, 19), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (0, 100, 0), (0, 100, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
            ];
            data = [
                {
                    id = "bribe_cost";
                    name = "Bribe Cost";
                    value = #nat({ min = 20; max = 30 });
                },
                {
                    id = "goblin_damage";
                    name = "Goblin Damage";
                    value = #nat({ min = 1; max = 3 });
                },
            ];
            choices = [
                {
                    id = "fight";
                    description = "Engage the goblin raiding party in combat.";
                    pathId = "fight_path";
                    requirement = null;
                },
                {
                    id = "bribe";
                    description = "Offer some of your resources to appease the goblins.";
                    pathId = "bribe_path";
                    requirement = null;
                },
                {
                    id = "intimidate";
                    description = "Use your strength to scare off the goblins.";
                    pathId = "intimidate_path";
                    requirement = ? #trait("strong");
                },
                {
                    id = "distract";
                    description = "Create a clever diversion to escape the goblins.";
                    pathId = "distract_path";
                    requirement = ? #trait("clever");
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "fight_path";
                    description = "You engage the goblin raiding party in combat.";
                    effects = [];
                    paths = [
                        {
                            weight = 3;
                            condition = null;
                            pathId = "fight_success";
                        },
                        {
                            weight = 2;
                            condition = null;
                            pathId = "fight_failure";
                        },
                    ];
                },
                {
                    id = "fight_success";
                    description = "You successfully fend off the goblin raiding party!";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "fight_failure";
                    description = "The goblins overwhelm you with their numbers.";
                    effects = [#damage(#dataField("goblin_damage"))];
                    paths = [];
                },
                {
                    id = "bribe_path";
                    description = "You attempt to bribe the goblins.";
                    effects = [#removeGold(#dataField("bribe_cost"))];
                    paths = [
                        {
                            weight = 4;
                            condition = ? #hasGold(#dataField("bribe_cost"));
                            pathId = "bribe_success";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("bribe_cost"));
                            pathId = "bribe_failure";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "bribe_no_gold";
                        },
                    ];
                },
                {
                    id = "bribe_success";
                    description = "The goblins accept your offering and leave you alone.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "bribe_failure";
                    description = "The goblins take your bribe but attack anyway!";
                    effects = [#damage(#dataField("goblin_damage"))];
                    paths = [];
                },
                {
                    id = "bribe_no_gold";
                    description = "The goblins see you don't have any gold and attack!";
                    effects = [#damage(#dataField("goblin_damage"))];
                    paths = [];
                },
                {
                    id = "intimidate_path";
                    description = "You attempt to intimidate the goblins.";
                    effects = [];
                    paths = [
                        {
                            weight = 4;
                            condition = null;
                            pathId = "intimidate_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "intimidate_failure";
                        },
                    ];
                },
                {
                    id = "intimidate_success";
                    description = "Your show of strength scares off the goblins.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "intimidate_failure";
                    description = "The goblins are not impressed and attack!";
                    effects = [#damage(#dataField("goblin_damage"))];
                    paths = [];
                },
                {
                    id = "distract_path";
                    description = "You attempt to create a clever diversion.";
                    effects = [];
                    paths = [
                        {
                            weight = 4;
                            condition = null;
                            pathId = "distract_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "distract_failure";
                        },
                    ];
                },
                {
                    id = "distract_success";
                    description = "Your clever diversion allows you to slip away unnoticed.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "distract_failure";
                    description = "The goblins see through your trick and attack!";
                    effects = [#damage(#dataField("goblin_damage"))];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand frozen, unable to decide. The goblins attack!";
                    effects = [#damage(#dataField("goblin_damage"))];
                    paths = [];
                },
            ];
        },
        {
            id = "knowledge_nexus";
            title = "Knowledge Nexus";
            description = "You enter a floating library of ancient wisdom.";
            icon = [
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (222, 184, 135), (222, 184, 135), (0, 0, 0), (222, 184, 135), (222, 184, 135), (0, 0, 0), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (139, 69, 19), (222, 184, 135), (222, 184, 135), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (222, 184, 135), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (139, 69, 19), (222, 184, 135), (139, 69, 19), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (139, 69, 19), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (139, 69, 19), (222, 184, 135), (139, 69, 19), (0, 0, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (0, 0, 255), (139, 69, 19), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (139, 69, 19), (222, 184, 135), (139, 69, 19), (0, 0, 255), (255, 255, 255), (0, 0, 0), (255, 255, 255), (0, 0, 0), (255, 255, 255), (0, 0, 255), (139, 69, 19), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (139, 69, 19), (222, 184, 135), (139, 69, 19), (0, 0, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (255, 255, 255), (0, 0, 255), (139, 69, 19), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (139, 69, 19), (222, 184, 135), (139, 69, 19), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (139, 69, 19), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (139, 69, 19), (222, 184, 135), (222, 184, 135), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (222, 184, 135), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (222, 184, 135), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
            ];
            data = [
                {
                    id = "study_cost";
                    name = "Study Cost";
                    value = #nat({ min = 10; max = 20 });
                },
                {
                    id = "skill_cost";
                    name = "Skill Cost";
                    value = #nat({ min = 15; max = 25 });
                },
                {
                    id = "map_cost";
                    name = "Map Cost";
                    value = #nat({ min = 20; max = 30 });
                },
            ];
            choices = [
                {
                    id = "study";
                    description = "Study ancient texts to increase your magic stat.";
                    pathId = "study_path";
                    requirement = null;
                },
                {
                    id = "learn_skill";
                    description = "Learn a new skill to increase your attack or defense.";
                    pathId = "learn_skill_path";
                    requirement = ? #trait("clever");
                },
                {
                    id = "decipher_map";
                    description = "Decipher an old map for a chance to discover a hidden location.";
                    pathId = "decipher_map_path";
                    requirement = null;
                },
                {
                    id = "leave";
                    description = "Leave the Knowledge Nexus.";
                    pathId = "leave_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "study_path";
                    description = "You attempt to study ancient texts.";
                    effects = [
                        #removeGold(#dataField("study_cost")),
                        #upgradeStat(#magic, #raw(1)),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("study_cost"));
                            pathId = "study_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "study_failure";
                        },
                    ];
                },
                {
                    id = "study_success";
                    description = "You study ancient texts and feel your magical knowledge expand.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "study_failure";
                    description = "You don't have enough gold to access the rare texts.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "learn_skill_path";
                    description = "You attempt to learn a new skill.";
                    effects = [
                        #removeGold(#dataField("skill_cost")),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("skill_cost"));
                            pathId = "learn_attack";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("skill_cost"));
                            pathId = "learn_defense";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "learn_skill_failure";
                        },
                    ];
                },
                {
                    id = "learn_attack";
                    description = "You learn combat techniques from ancient scrolls.";
                    effects = [#upgradeStat(#attack, #raw(1))];
                    paths = [];
                },
                {
                    id = "learn_defense";
                    description = "You study defensive strategies from old tomes.";
                    effects = [#upgradeStat(#defense, #raw(1))];
                    paths = [];
                },
                {
                    id = "learn_skill_failure";
                    description = "You don't have enough gold to learn a new skill.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "decipher_map_path";
                    description = "You attempt to decipher an ancient map.";
                    effects = [
                        #removeGold(#dataField("map_cost")),
                    ];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("map_cost"));
                            pathId = "map_success";
                        },
                        {
                            weight = 2;
                            condition = ? #hasGold(#dataField("map_cost"));
                            pathId = "map_failure";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "map_no_gold";
                        },
                    ];
                },
                {
                    id = "map_success";
                    description = "You successfully decipher an ancient map, revealing a hidden location.";
                    effects = [#addItem(#raw("treasure_map"))];
                    paths = [];
                },
                {
                    id = "map_failure";
                    description = "Despite your efforts, you fail to decipher the map completely.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "map_no_gold";
                    description = "You don't have enough gold to access the map archives.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "leave_path";
                    description = "You leave the Knowledge Nexus, your mind brimming with new information.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You're overwhelmed by the vast knowledge surrounding you, unable to decide what to do.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "lost_elfling";
            title = "Lost Elfling";
            description = "You hear the faint cries of a young elf, seemingly lost and separated from their clan.";
            icon = [
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (0, 0, 0), (0, 0, 0), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (0, 0, 0), (0, 0, 0), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (34, 139, 34), (34, 139, 34), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
            ];
            data = [];
            choices = [
                {
                    id = "help";
                    description = "Offer assistance to the lost elfling.";
                    pathId = "help_path";
                    requirement = null;
                },
                {
                    id = "abandon";
                    description = "Continue on your way, leaving the elfling to its fate.";
                    pathId = "abandon_path";
                    requirement = null;
                },
                {
                    id = "investigate";
                    description = "Carefully investigate the area before approaching the elfling.";
                    pathId = "investigate_path";
                    requirement = null;
                },
                {
                    id = "use_magic";
                    description = "Use magic to locate the elfling's clan or create a safe path.";
                    pathId = "use_magic_path";
                    requirement = ? #stat((#magic, 2));
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "help_path";
                    description = "You attempt to help the lost elfling.";
                    effects = [];
                    paths = [
                        {
                            weight = 4;
                            condition = null;
                            pathId = "help_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "help_danger";
                        },
                    ];
                },
                {
                    id = "help_success";
                    description = "You successfully help the elfling and reunite them with their clan.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "help_danger";
                    description = "Your attempt to help leads you into a dangerous situation.";
                    effects = [#damage(#random(1, 3))];
                    paths = [];
                },
                {
                    id = "abandon_path";
                    description = "You ignore the elfling's cries and continue on your way.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "investigate_path";
                    description = "You carefully investigate the area.";
                    effects = [];
                    paths = [
                        {
                            weight = 3;
                            condition = null;
                            pathId = "investigate_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "investigate_danger";
                        },
                    ];
                },
                {
                    id = "investigate_success";
                    description = "Your careful investigation reveals a safe path to the elfling.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "investigate_danger";
                    description = "While investigating, you stumble into a hidden danger.";
                    effects = [#damage(#random(1, 2))];
                    paths = [];
                },
                {
                    id = "use_magic_path";
                    description = "You attempt to use magic to help the elfling.";
                    effects = [];
                    paths = [
                        {
                            weight = 9;
                            condition = null;
                            pathId = "magic_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "magic_danger";
                        },
                    ];
                },
                {
                    id = "magic_success";
                    description = "Your magic successfully guides the elfling back to their clan.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "magic_danger";
                    description = "Your magic attracts unwanted attention from forest spirits.";
                    effects = [#damage(#random(1, 2))];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand frozen, unable to decide what to do about the lost elfling.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "mysterious_structure";
            title = "Mysterious Structure";
            description = "You encounter a pyramid-like structure with glowing runes, overgrown by vines. A sealed entrance beckons.";
            icon = [
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (210, 180, 140), (210, 180, 140), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (255, 215, 0), (169, 169, 169), (169, 169, 169), (255, 215, 0), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (255, 215, 0), (255, 215, 0), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140), (135, 206, 235)],
                [(135, 206, 235), (210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (255, 215, 0), (255, 215, 0), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140), (135, 206, 235)],
                [(210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140)],
                [(210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140)],
                [(210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (0, 0, 0), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (0, 0, 0), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140)],
                [(34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (169, 169, 169), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
            ];
            data = [
                {
                    id = "ambush_damage";
                    name = "Ambush Damage";
                    value = #nat({ min = 0; max = 5 });
                },
                {
                    id = "trap_damage";
                    name = "Trap Damage";
                    value = #nat({ min = 1; max = 3 });
                },
                {
                    id = "forceful_entry_damage";
                    name = "Forceful Entry Damage";
                    value = #nat({ min = 1; max = 5 });
                },
            ];
            choices = [
                {
                    id = "skip";
                    description = "Ignore the structure and continue exploring elsewhere.";
                    pathId = "skip_path";
                    requirement = null;
                },
                {
                    id = "forceful_entry";
                    description = "Attempt to create an opening using brute force or basic tools. Could be dangerous.";
                    pathId = "forceful_entry_path";
                    requirement = null;
                },
                {
                    id = "sacrifice";
                    description = "Offer a random resource or item to the structure, hoping to gain entry or unlock its secrets.";
                    pathId = "sacrifice_path";
                    requirement = null;
                },
                {
                    id = "secret_entrance";
                    description = "Use the secret side entrance that was found from being so perceptive.";
                    pathId = "secret_entrance_path";
                    requirement = ? #trait("perceptive");
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "secret_entrance_path";
                    description = "You find a hidden entrance and carefully make your way inside.";
                    effects = [];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "explore_treasure_room";
                        },
                    ];
                },
                {
                    id = "forceful_entry_path";
                    description = "You attempt to force your way into the structure.";
                    effects = [];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "forceful_entry_damage";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "forceful_entry_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "forceful_entry_failure";
                        },
                    ];
                },
                {
                    id = "forceful_entry_damage";
                    description = "You hurt yourself trying to force into the entrance.";
                    effects = [#damage(#dataField("forceful_entry_damage"))];
                    paths = [];
                },
                {
                    id = "forceful_entry_success";
                    description = "You manage to create an opening and enter the structure.";
                    effects = [];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "explore_structure";
                        },
                    ];
                },
                {
                    id = "forceful_entry_failure";
                    description = "Your attempts to force your way inside are unsuccessful.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "sacrifice_path";
                    description = "You make an offering to the structure and it allows you to enter safely.";
                    effects = [#removeItem(#random)];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "explore_treasure_room";
                        },
                    ];
                },
                {
                    id = "skip_path";
                    description = "You decide to leave the structure alone and continue exploring elsewhere.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "explore_structure";
                    description = "You explore the mysterious structure.";
                    effects = [];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "structure_ambush";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "structure_trap";
                        },
                        {
                            weight = 2;
                            condition = null;
                            pathId = "explore_treasure_room";
                        },
                    ];
                },
                {
                    id = "structure_ambush";
                    description = "You are ambushed by a group of hostile creatures!";
                    effects = [#damage(#dataField("ambush_damage"))];
                    paths = [];
                },
                {
                    id = "structure_trap";
                    description = "You trigger a trap!";
                    effects = [#damage(#dataField("trap_damage"))];
                    paths = [];
                },
                {
                    id = "explore_treasure_room";
                    description = "You explore a hidden chamber within the structure.";
                    effects = [];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "treasure_found";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "no_treasure";
                        },
                    ];
                },
                {
                    id = "treasure_found";
                    description = "You discover a hidden chamber containing a small amount of treasure.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "no_treasure";
                    description = "You find nothing of interest inside.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You don't seem to find the structure interesting and move on.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "mystic_forge";
            title = "Mystic Forge";
            description = "You enter a magical smithy where the hammers swing themselves and the anvils occasionally burp fire.";
            icon = [
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20)],
                [(70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (250, 200, 0), (250, 200, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (200, 100, 0), (200, 100, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (0, 0, 0), (0, 0, 0), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
                [(70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20), (70, 40, 20)],
            ];
            data = [
                {
                    id = "upgrade_cost";
                    name = "Upgrade Cost";
                    value = #nat({ min = 20; max = 30 });
                },
                {
                    id = "reforge_cost";
                    name = "Reforge Cost";
                    value = #nat({ min = 15; max = 25 });
                },
                {
                    id = "craft_cost";
                    name = "Craft Cost";
                    value = #nat({ min = 25; max = 35 });
                },
            ];
            choices = [
                {
                    id = "upgrade";
                    description = "Upgrade your equipment. 60% of the time, it works every time.";
                    pathId = "upgrade_path";
                    requirement = null;
                },
                {
                    id = "reforge";
                    description = "Reforge an item. It's like a makeover, but for swords!";
                    pathId = "reforge_path";
                    requirement = null;
                },
                {
                    id = "craft";
                    description = "Craft a special item. Warning: May result in unexpected chicken statues.";
                    pathId = "craft_path";
                    requirement = ? #class_("artificer");
                },
                {
                    id = "leave";
                    description = "Leave the Mystic Forge. The heat was getting unbearable anyway.";
                    pathId = "leave_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "upgrade_path";
                    description = "You attempt to upgrade your equipment.";
                    effects = [#removeGold(#dataField("upgrade_cost"))];
                    paths = [
                        {
                            weight = 3;
                            condition = ? #hasGold(#dataField("upgrade_cost"));
                            pathId = "upgrade_success";
                        },
                        {
                            weight = 2;
                            condition = ? #hasGold(#dataField("upgrade_cost"));
                            pathId = "upgrade_failure";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "upgrade_no_gold";
                        },
                    ];
                },
                {
                    id = "upgrade_success";
                    description = "The forge bellows with approval. Your equipment feels more... equipment-y.";
                    effects = [
                        #upgradeStat(#attack, #raw(1)),
                        #upgradeStat(#defense, #raw(1)),
                    ];
                    paths = [];
                },
                {
                    id = "upgrade_failure";
                    description = "The forge hiccups. Your gold vanishes, leaving behind a faint smell of burnt toast.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "upgrade_no_gold";
                    description = "The forge eyes your empty pockets and sighs dramatically.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "reforge_path";
                    description = "You attempt to reforge an item.";
                    effects = [#removeGold(#dataField("reforge_cost"))];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("reforge_cost"));
                            pathId = "reforge_attack";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("reforge_cost"));
                            pathId = "reforge_defense";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "reforge_no_gold";
                        },
                    ];
                },
                {
                    id = "reforge_attack";
                    description = "Your item emerges from the forge, looking suspiciously similar but feeling somehow different.";
                    effects = [#upgradeStat(#attack, #raw(1))];
                    paths = [];
                },
                {
                    id = "reforge_defense";
                    description = "Your item emerges from the forge, looking suspiciously similar but feeling somehow different.";
                    effects = [#upgradeStat(#defense, #raw(1))];
                    paths = [];
                },
                {
                    id = "reforge_no_gold";
                    description = "The forge snorts derisively at your lack of funds. Even magical anvils have bills to pay.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "craft_path";
                    description = "You attempt to craft a special item.";
                    effects = [#removeGold(#dataField("craft_cost"))];
                    paths = [
                        {
                            weight = 2;
                            condition = ? #hasGold(#dataField("craft_cost"));
                            pathId = "craft_success";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("craft_cost"));
                            pathId = "craft_failure";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "craft_no_gold";
                        },
                    ];
                },
                {
                    id = "craft_success";
                    description = "The forge erupts in a shower of sparks. You've created something... interesting.";
                    effects = [#addItem(#raw("crystal"))];
                    paths = [];
                },
                {
                    id = "craft_failure";
                    description = "The forge burps loudly. Your gold is gone, and you're left holding... is that a rubber chicken?";
                    effects = [];
                    paths = [];
                },
                {
                    id = "craft_no_gold";
                    description = "The forge grumbles about 'in this economy' and 'the cost of phoenix feathers these days'.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "leave_path";
                    description = "You leave the Mystic Forge, your eyebrows slightly singed but your spirit unquenched.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand frozen, mesmerized by the dancing flames and floating hammers.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "sinking_boat";
            title = "Sinking Boat";
            description = "You come across a small boat sinking in a nearby river. The passengers are calling for help.";
            icon = [
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (135, 206, 235), (135, 206, 235)],
                [(0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255)],
                [(0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255)],
                [(0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255)],
                [(0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255)],
                [(0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255)],
                [(0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255), (0, 0, 255)],
            ];
            data = [
                {
                    id = "swimming_damage";
                    name = "Swimming Damage";
                    value = #nat({ min = 1; max = 3 });
                },
                {
                    id = "spell_damage";
                    name = "Spell Damage";
                    value = #nat({ min = 1; max = 2 });
                },
            ];
            choices = [
                {
                    id = "rescue_swimming";
                    description = "Swim out to rescue the passengers.";
                    pathId = "rescue_swimming_path";
                    requirement = null;
                },
                {
                    id = "cast_spell";
                    description = "Cast a water-walking spell to rescue the passengers.";
                    pathId = "cast_spell_path";
                    requirement = ? #stat((#magic, 2));
                },
                {
                    id = "disregard";
                    description = "Disregard the sinking boat and continue on your way.";
                    pathId = "disregard_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "rescue_swimming_path";
                    description = "You attempt to swim out and rescue the passengers.";
                    effects = [];
                    paths = [
                        {
                            weight = 3;
                            condition = null;
                            pathId = "swimming_success";
                        },
                        {
                            weight = 2;
                            condition = null;
                            pathId = "swimming_difficulty";
                        },
                    ];
                },
                {
                    id = "swimming_success";
                    description = "You successfully swim out and rescue the passengers.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "swimming_difficulty";
                    description = "The current is stronger than you anticipated.";
                    effects = [#damage(#dataField("swimming_damage"))];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "swimming_rescue";
                        },
                    ];
                },
                {
                    id = "swimming_rescue";
                    description = "You manage to rescue the passengers, but at a cost to your health.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "cast_spell_path";
                    description = "You attempt to cast a water-walking spell to rescue the passengers.";
                    effects = [];
                    paths = [
                        {
                            weight = 4;
                            condition = null;
                            pathId = "spell_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "spell_difficulty";
                        },
                    ];
                },
                {
                    id = "spell_success";
                    description = "Your water-walking spell allows you to easily rescue all passengers.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "spell_difficulty";
                    description = "Your spell falters midway through the rescue.";
                    effects = [#damage(#dataField("spell_damage"))];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "spell_rescue";
                        },
                    ];
                },
                {
                    id = "spell_rescue";
                    description = "Despite the setback, you manage to complete the rescue.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "disregard_path";
                    description = "You disregard the calls for help and continue on your way, leaving the passengers to their fate.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You don't seem to notice and carry on.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "trapped_druid";
            title = "Trapped Druid";
            description = "You come across a druid entangled in a strange, pulsating magical snare. They call out for help.";
            icon = [
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (210, 180, 140), (0, 0, 0), (210, 180, 140), (210, 180, 140), (0, 0, 0), (210, 180, 140), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (210, 180, 140), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (255, 0, 0), (255, 0, 0), (255, 0, 0), (255, 0, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (255, 0, 0), (255, 0, 0), (255, 0, 0), (255, 0, 0), (255, 0, 0), (255, 0, 0), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
                [(34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34)],
            ];
            data = [
                {
                    id = "direct_damage";
                    name = "Direct Attempt Damage";
                    value = #nat({ min = 2; max = 4 });
                },
                {
                    id = "nature_damage";
                    name = "Nature Skills Damage";
                    value = #nat({ min = 1; max = 2 });
                },
                {
                    id = "search_damage";
                    name = "Search Damage";
                    value = #nat({ min = 1; max = 3 });
                },
            ];
            choices = [
                {
                    id = "free_directly";
                    description = "Attempt to free the druid directly from the magical snare.";
                    pathId = "free_directly_path";
                    requirement = null;
                },
                {
                    id = "use_nature_skills";
                    description = "Use your nature-speaking abilities to communicate with the forest and find a safe way to free the druid.";
                    pathId = "use_nature_skills_path";
                    requirement = ? #trait("naturalist");
                },
                {
                    id = "find_alternative_solution";
                    description = "Search the area for clues or tools that might help free the druid.";
                    pathId = "find_alternative_solution_path";
                    requirement = null;
                },
                {
                    id = "leave_alone";
                    description = "Decide the situation is too risky and leave the druid to their fate.";
                    pathId = "leave_alone_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "free_directly_path";
                    description = "You attempt to free the druid directly from the magical snare.";
                    effects = [];
                    paths = [
                        {
                            weight = 1;
                            condition = null;
                            pathId = "direct_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "direct_failure";
                        },
                    ];
                },
                {
                    id = "direct_success";
                    description = "You successfully free the druid from the magical snare.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "direct_failure";
                    description = "The magical snare reacts violently to your attempt.";
                    effects = [#damage(#dataField("direct_damage"))];
                    paths = [];
                },
                {
                    id = "use_nature_skills_path";
                    description = "You use your nature skills to attempt to disarm the snare.";
                    effects = [];
                    paths = [
                        {
                            weight = 4;
                            condition = null;
                            pathId = "nature_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "nature_failure";
                        },
                    ];
                },
                {
                    id = "nature_success";
                    description = "Your nature skills allow you to safely disarm the snare and free the druid.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "nature_failure";
                    description = "Despite your skills, the snare proves too complex to disarm safely.";
                    effects = [#damage(#dataField("nature_damage"))];
                    paths = [];
                },
                {
                    id = "find_alternative_solution_path";
                    description = "You search the area for an alternative solution.";
                    effects = [];
                    paths = [
                        {
                            weight = 2;
                            condition = null;
                            pathId = "search_success";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "search_failure";
                        },
                    ];
                },
                {
                    id = "search_success";
                    description = "You find a magical artifact nearby that helps neutralize the snare.";
                    effects = [#reward];
                    paths = [];
                },
                {
                    id = "search_failure";
                    description = "Your search attracts unwanted attention from forest creatures.";
                    effects = [#damage(#dataField("search_damage"))];
                    paths = [];
                },
                {
                    id = "leave_alone_path";
                    description = "You decide the risk is too great and leave the druid to their fate.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You don't seem to hear them and continue walking.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "travelling_bard";
            title = "Travelling Bard";
            description = "You encounter a bard whose lute is suspiciously in tune for someone who's been on the road.";
            icon = [
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 223, 186), (255, 223, 186), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 223, 186), (255, 223, 186), (255, 223, 186), (255, 223, 186), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 223, 186), (255, 223, 186), (139, 69, 19), (255, 223, 186), (255, 223, 186), (255, 223, 186), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 223, 186), (255, 223, 186), (255, 223, 186), (139, 69, 19), (255, 223, 186), (255, 223, 186), (255, 223, 186), (255, 223, 186), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 0, 0), (0, 0, 255), (255, 255, 0), (255, 0, 0), (0, 0, 255), (255, 255, 0), (255, 0, 0), (0, 0, 255), (255, 255, 0), (255, 0, 0), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (139, 69, 19), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (139, 69, 19), (139, 69, 19), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (139, 69, 19), (139, 69, 19), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (34, 139, 34), (135, 206, 235), (135, 206, 235)],
            ];
            data = [
                {
                    id = "inspiration_cost";
                    name = "Inspiration Cost";
                    value = #nat({ min = 10; max = 20 });
                },
                {
                    id = "tales_cost";
                    name = "Tales Cost";
                    value = #nat({ min = 15; max = 25 });
                },
                {
                    id = "request_cost";
                    name = "Request Cost";
                    value = #nat({ min = 20; max = 30 });
                },
            ];
            choices = [
                {
                    id = "seek_inspiration";
                    description = "Seek inspiration from the bard. Warning: May cause spontaneous poetry.";
                    pathId = "seek_inspiration_path";
                    requirement = null;
                },
                {
                    id = "listen_tales";
                    description = "Listen to the bard's tales. 50% history, 50% gossip, 100% embellished.";
                    pathId = "listen_tales_path";
                    requirement = null;
                },
                {
                    id = "request_song";
                    description = "Request a specific song. Hope you like 'Wonderwall'.";
                    pathId = "request_song_path";
                    requirement = ? #trait("clever");
                },
                {
                    id = "leave";
                    description = "Leave the bard. Your ears could use a break anyway.";
                    pathId = "leave_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "seek_inspiration_path";
                    description = "You seek inspiration from the bard.";
                    effects = [#removeGold(#dataField("inspiration_cost"))];
                    paths = [
                        {
                            weight = 3;
                            condition = ? #hasGold(#dataField("inspiration_cost"));
                            pathId = "inspiration_success";
                        },
                        {
                            weight = 2;
                            condition = ? #hasGold(#dataField("inspiration_cost"));
                            pathId = "inspiration_failure";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "no_gold_inspiration";
                        },
                    ];
                },
                {
                    id = "inspiration_success";
                    description = "The bard's words stir your soul. You feel more... magical. Or was that just indigestion?";
                    effects = [#upgradeStat(#magic, #raw(1))];
                    paths = [];
                },
                {
                    id = "inspiration_failure";
                    description = "The bard's inspiration misses the mark. You now know way too much about the mating habits of geese.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "no_gold_inspiration";
                    description = "The bard raises an eyebrow at your empty pockets. Inspiration doesn't pay for itself, you know.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "listen_tales_path";
                    description = "You listen to the bard's tales.";
                    effects = [#removeGold(#dataField("tales_cost"))];
                    paths = [
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("tales_cost"));
                            pathId = "tales_attack";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("tales_cost"));
                            pathId = "tales_defense";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "no_gold_tales";
                        },
                    ];
                },
                {
                    id = "tales_attack";
                    description = "The bard's tales of heroic deeds fill you with courage. You feel stronger, or at least less likely to run from a fight.";
                    effects = [#upgradeStat(#attack, #raw(1))];
                    paths = [];
                },
                {
                    id = "tales_defense";
                    description = "The bard's stories of cunning heroes sharpen your wits. You're now 30% more likely to spot a bad deal... like this one.";
                    effects = [#upgradeStat(#defense, #raw(1))];
                    paths = [];
                },
                {
                    id = "no_gold_tales";
                    description = "The bard stops mid-sentence, looking expectantly at your coin purse. Seems this tale has a cover charge.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "request_song_path";
                    description = "You request a specific song from the bard.";
                    effects = [#removeGold(#dataField("request_cost"))];
                    paths = [
                        {
                            weight = 2;
                            condition = ? #hasGold(#dataField("request_cost"));
                            pathId = "song_success";
                        },
                        {
                            weight = 1;
                            condition = ? #hasGold(#dataField("request_cost"));
                            pathId = "song_failure";
                        },
                        {
                            weight = 1;
                            condition = null;
                            pathId = "no_gold_song";
                        },
                    ];
                },
                {
                    id = "song_success";
                    description = "The bard plays your request with surprising skill. You receive a magical token of appreciation from the universe.";
                    effects = [#addItem(#raw("crystal"))];
                    paths = [];
                },
                {
                    id = "song_failure";
                    description = "The bard butchers your request so badly, nearby plants wilt. You're pretty sure you've just lost brain cells.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "no_gold_song";
                    description = "The bard strums a chord that sounds suspiciously like a cash register. No gold, no song.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "leave_path";
                    description = "You leave the bard, humming a tune that will be stuck in your head for days. Thanks a lot.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You stand there, caught between fight or flight as the bard clears his throat.";
                    effects = [];
                    paths = [];
                },
            ];
        },
        {
            id = "wandering_alchemist";
            title = "Wandering Alchemist";
            description = "You encounter a wandering alchemist, their pack filled with bubbling vials and aromatic herbs.";
            icon = [
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 192, 203), (255, 192, 203), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 192, 203), (255, 192, 203), (255, 192, 203), (255, 192, 203), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 192, 203), (255, 192, 203), (255, 192, 203), (255, 192, 203), (255, 192, 203), (255, 192, 203), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (255, 192, 203), (255, 192, 203), (255, 192, 203), (0, 0, 0), (0, 0, 0), (255, 192, 203), (255, 192, 203), (255, 192, 203), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (165, 42, 42), (165, 42, 42), (0, 0, 255), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (0, 255, 0), (165, 42, 42), (165, 42, 42), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (0, 0, 0), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (165, 42, 42), (0, 0, 0), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (139, 69, 19), (139, 69, 19), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (139, 69, 19), (139, 69, 19), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
                [(135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (0, 0, 0), (0, 0, 0), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235), (135, 206, 235)],
            ];
            data = [
                {
                    id = "vial_of_acid_cost";
                    name = "Vial of Acid Cost";
                    value = #nat({ min = 30; max = 35 });
                },
            ];
            choices = [
                {
                    id = "trade_herbs";
                    description = "Trade your herbs for a vial of acid.";
                    pathId = "trade_herbs_path";
                    requirement = ? #item("herbs");
                },
                {
                    id = "buy_vial_of_acid";
                    description = "Buy a vial of acid for some gold.";
                    pathId = "buy_vial_of_acid_path";
                    requirement = null;
                },
                {
                    id = "learn";
                    description = "Try to learn from the alchemist.";
                    pathId = "learn_path";
                    requirement = ? #trait("intelligent");
                },
                {
                    id = "decline";
                    description = "Politely decline and continue on your way.";
                    pathId = "decline_path";
                    requirement = null;
                },
            ];
            undecidedPathId = "undecided_path";
            paths = [
                {
                    id = "trade_herbs_path";
                    description = "You trade your herbs for a vial of acid.";
                    effects = [
                        #removeItem(#specific(#raw("herbs"))),
                        #addItem(#raw("vial_of_acid")),
                    ];
                    paths = [];
                },
                {
                    id = "buy_vial_of_acid_path";
                    description = "You purchase a vial of acid from the alchemist.";
                    effects = [
                        #removeGold(#dataField("vial_of_acid_cost")),
                        #addItem(#raw("vial_of_acid")),
                    ];
                    paths = [];
                },
                {
                    id = "learn_path";
                    description = "You try to learn from the alchemist.";
                    effects = [];
                    paths = [
                        {
                            weight = 3;
                            condition = null;
                            pathId = "learn_success";
                        },
                        {
                            weight = 2;
                            condition = null;
                            pathId = "learn_failure";
                        },
                    ];
                },
                {
                    id = "learn_success";
                    description = "You successfully learn from the alchemist!";
                    effects = [#addTrait(#raw("alchemist"))];
                    paths = [];
                },
                {
                    id = "learn_failure";
                    description = "The alchemist's instructions are too complex. You fail to learn anything.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "decline_path";
                    description = "You politely decline the alchemist's offers and continue on your journey.";
                    effects = [];
                    paths = [];
                },
                {
                    id = "undecided_path";
                    description = "You ignore them and continue walking down the path.";
                    effects = [];
                    paths = [];
                },
            ];
        },
    ];
};
