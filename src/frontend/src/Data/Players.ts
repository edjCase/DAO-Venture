import { Deity, FieldPosition, PlayerSkills } from "../ic-agent/PlayerLedger";

export type Player = {
    'name': string,
    'position': FieldPosition,
    'deity': Deity,
    'skills': PlayerSkills
}

export type Team = {
    name: string;
    logoUrl: string;
    tokenName: string;
    tokenSymbol: string;
    players: Player[];
};

export type Division = { name: string; teams: Team[] };

export const divisions: Division[] = [
    {
        "name": "Division 1",
        "teams": [
            {
                "name": "Crabz",
                "logoUrl": "https://imgs.search.brave.com/OFu2Rv3v86otnalo0qA4e59PZtqCmw5IOZIIH5PIH8o/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90NC5m/dGNkbi5uZXQvanBn/LzAxLzc3LzEzLzQ1/LzM2MF9GXzE3NzEz/NDU0OF9kN1ljYlBW/TDVselMxWG5mMTlC/QXEybGFKU2U1QnV2/Zi5qcGc",
                "tokenName": "Crabz",
                "tokenSymbol": "CRABZ",
                "players": [
                    {
                        "name": "Shelldon Pinch",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Coraline Claw",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 0,
                            "defense": 2,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Sandy Shore",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": 0,
                            "piety": 1,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Barnacle Bill",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Tidepool Tim",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -1,
                            "throwingPower": 0,
                            "catching": 1,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Wharf Willy",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 0,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Ocean Oliver",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": 2,
                            "piety": -2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Waverly Waters",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Kelpie Krab",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Anemone Andy",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Reef Ricky",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Mussel Mike",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -1,
                            "throwingPower": 0,
                            "catching": 1,
                            "defense": 0,
                            "piety": -2,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Bubbly Bob",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Tsunami Tami",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Harbor Harriot",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Beachcomber Betty",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    }
                ]
            },
            {
                "name": "Lobsterz",
                "logoUrl": "https://imgs.search.brave.com/cIAAkBmDWBtXzxwWspYcqbg2M2aiTOKDqGAsuGkhY_I/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAyLzA0LzczLzky/LzM2MF9GXzIwNDcz/OTI5MV9LM25mZEdK/d0FrSjlLQnVLUlZp/NHhtWEtVaU94OXlR/Si5qcGc",
                "tokenName": "Lobsterz",
                "tokenSymbol": "LOBZ",
                "players": [
                    {
                        "name": "Lobster Larry",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Coral Courtney",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": 0,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Buoyant Benny",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Reefy Ruth",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Shelly Shore",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Pincer Paul",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 0,
                            "defense": 2,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Tidal Tina",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 0,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Oceanic Olga",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Abyss Andy",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Marina Mary",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Current Chris",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Seaweed Sally",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Whirlpool Willie",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Surfing Samantha",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Nautical Nancy",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Divey Dave",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 1,
                            "defense": 0,
                            "piety": -2,
                            "speed": 0
                        }
                    }
                ]
            },
            {
                "name": "Jellyz",
                "logoUrl": "https://imgs.search.brave.com/4ZUlZt5Y_B7DSKkE3GO58ZVXlM2RxGkoOukG7U6Gqqk/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9pbWcu/ZnJlZXBpay5jb20v/ZnJlZS12ZWN0b3Iv/amVsbHlmaXNoLXNl/YS1hbmltYWwtY2Fy/dG9vbi1zdGlja2Vy/XzEzMDgtNzg1MzAu/anBnP3NpemU9NjI2/JmV4dD1qcGc",
                "tokenName": "Jellyz",
                "tokenSymbol": "JELZ",
                "players": [
                    {
                        "name": "Jellybean Jill",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -1,
                            "throwingPower": 0,
                            "catching": 1,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Tentacle Ted",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Stinger Steve",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": 1,
                            "piety": -1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Bubbly Bill",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Floaty Frank",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Mano-War Maria",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 1,
                            "throwingPower": -2,
                            "catching": 0,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Pulsing Polly",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Drifty Dave",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 2,
                            "defense": -1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Moonbeam Molly",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Luminous Lou",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Hydro Harry",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -1,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Glowy Gwen",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Blubber Bob",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            "mischief": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 1,
                            "defense": -2,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Necton Ned",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -2,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Cnidarian Cindy",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 2,
                            "defense": -1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Zephyr Zoe",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    }
                ]
            },
            {
                "name": "Toadz",
                "logoUrl": "https://imgs.search.brave.com/Rm7Nj0SD_nUMzAjs3we-upMoynWtEwkB2WacPgf9IAQ/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS5pc3RvY2twaG90/by5jb20vaWQvMTIw/OTE0MjI2Mi92ZWN0/b3IvZnJvZy1sb2dv/LmpwZz9zPTYxMng2/MTImdz0wJms9MjAm/Yz02YU4tSF83eUNH/bEwzQmZ1YVcwY3hl/cmo4bzNmd25WZkVP/TnZMOHVxVE80PQ",
                "tokenName": "Toadz",
                "tokenSymbol": "TOADZ",
                "players": [
                    {
                        "name": "Toadstool Todd",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Hoppy Hank",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Boggy Bill",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Pond Paul",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Croaky Chris",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Lily Lily",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Ribbit Rick",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Swampy Sue",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Muddy Mike",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Warty Wendy",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Bumpy Bob",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Puddle Pete",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Tadpole Tim",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Froggy Fran",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Algae Amy",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Marshy Matt",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    }
                ]
            },
            {
                "name": "Squidz",
                "logoUrl": "https://imgs.search.brave.com/ejjzShq4jh4B2_l43F-or_BchEQdx9DwRic6SIV5T9A/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudGhlbm91bnBy/b2plY3QuY29tL3Bu/Zy81ODM5NTYxLTIw/MC5wbmc",
                "tokenName": "Squidz",
                "tokenSymbol": "SQUIDZ",
                "players": [
                    {
                        "name": "Inky Ian",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Squiggly Steve",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Darting Dan",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Tentacle Tom",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Jetty Jerry",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Kraken Kevin",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Salty Sam",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Ocean Olaf",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Coral Carly",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Sinker Scott",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Reef Randalf",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Mantle Mason",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 2,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Deepsea Dean",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Barnacle Brad",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Wave Walter",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Gill Gary",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": 1
                        }
                    }
                ]
            },
            {
                "name": "Salamanderz",
                "logoUrl": "https://imgs.search.brave.com/0WHTTsaSLs4aqG8P9vON1KcL6ID84ARAEfEhdk_LJUc/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9jZG4u/dmVjdG9yc3RvY2su/Y29tL2kvcHJldmll/dy0xeC81OS84NS9z/YWxhbWFuZGVyLWhh/bmQtZHJhd24tc2tl/dGNoLWljb24tdmVj/dG9yLTE5Mzk1OTg1/LmpwZw",
                "tokenName": "Salamanderz",
                "tokenSymbol": "SALMZ",
                "players": [
                    {
                        "name": "Sunny Sal",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Newt Nate",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -1,
                            "piety": -2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Gilly Gil",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Axolotl Alex",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 2,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Crested Cory",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Mudskipper Max",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Lava Lance",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -2,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -1,
                            "piety": 1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Skink Steve",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": -2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Siren Sam",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": -2,
                            "defense": 2,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Triton Troy",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 1,
                            "throwingPower": -2,
                            "catching": 0,
                            "defense": -1,
                            "piety": 1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Firefly Finn",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 0,
                            "piety": 2,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Slimy Sean",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 1,
                            "defense": -2,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Camo Kyle",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Gecko Gary",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 2,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Hydra Harry",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": 1,
                            "piety": 2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Mossy Marty",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 1,
                            "defense": -1,
                            "piety": 0,
                            "speed": 1
                        }
                    }
                ]
            }
        ]
    },
    {
        "name": "Division 2",
        "teams": [
            {
                "name": "Barnaclez",
                "logoUrl": "https://imgs.search.brave.com/ir4LXuCwuUxldHx7W4mSZzUOIifEzo6bSmjoAsOVvlc/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9kb2Rv/LmFjL25wL2ltYWdl/cy9hL2E0L0Fjb3Ju/X0Jhcm5hY2xlX05I/X0ljb24ucG5n",
                "tokenName": "Barnaclez",
                "tokenSymbol": "BARNZ",
                "players": [
                    {
                        "name": "Buoyant Barry",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 0,
                            "defense": 1,
                            "piety": -2,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Marine Mark",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Salty Steve",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Ocean Owen",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Coral Cooper",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Tidepool Tom",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 2,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Harbor Harry",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 1,
                            "defense": -2,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Anchor Andy",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Seaweed Simon",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Barny Bernard",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -2,
                            "throwingPower": 2,
                            "catching": -1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Deckhand Dan",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Reef Randy",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Manta Ray",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -1,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Nautical Nate",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Mollusk Mike",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 0,
                            "defense": -1,
                            "piety": 1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Guppy Gary",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    }
                ]
            },
            {
                "name": "Newtz",
                "logoUrl": "https://imgs.search.brave.com/yOFowXI6oh5bfO45qXKdqFMR9I2J0pFMD1n9WNWz0f8/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudGhlbm91bnBy/b2plY3QuY29tL3Bu/Zy8yNTM1NzI2LTIw/MC5wbmc",
                "tokenName": "Newtz",
                "tokenSymbol": "NEWTZ",
                "players": [
                    {
                        "name": "Newt Nolan",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Salamander Sam",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -1,
                            "piety": -2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Gilly Gary",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Triton Travis",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 1,
                            "catching": -2,
                            "defense": 2,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Eft Eddie",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": -1,
                            "piety": 2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Sticky Stuart",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 1,
                            "piety": -2,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Aquatic Alex",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -2,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -1,
                            "piety": 1,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Mudskipper Mark",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": -2,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Wetland Walt",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": 2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Slick Steve",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": -1,
                            "piety": 2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Paddle Paul",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": -2,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Swimmy Scott",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": 1,
                            "defense": 0,
                            "piety": 2,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Lagoon Leo",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -1,
                            "piety": -2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Boggy Blake",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": -2,
                            "defense": 2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Pond Peter",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 0,
                            "catching": 1,
                            "defense": -1,
                            "piety": 2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Marshland Mike",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": 2,
                            "throwingPower": -1,
                            "catching": -2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 2
                        }
                    }
                ]
            },
            {
                "name": "Cuttlefizh",
                "logoUrl": "https://imgs.search.brave.com/hiYh3mpfyCj0U3lggVQ5Zj8mwN7HqHZqtYPNPjjk7lo/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9zdGF0/aWMudGhlbm91bnBy/b2plY3QuY29tL3Bu/Zy8yMDQyMTcyLTIw/MC5wbmc",
                "tokenName": "Cuttlefizh",
                "tokenSymbol": "CTLFZ",
                "players": [
                    {
                        "name": "Cephalo Carlos",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Ink Ian",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -1,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Squiddy Steve",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Tentacle Timmy",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Jet Jack",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Siphon Sam",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Mantle Max",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -1,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Beak Ben",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Kraken Keith",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Armstrong Arthur",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": -2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Camo Kevin",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Nauti Nick",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Reef Rudy",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Deepsea Dave",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Floaty Phil",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -1,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Ocean Olive",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    }
                ]
            },
            {
                "name": "Turtlez",
                "logoUrl": "https://imgs.search.brave.com/ZZao2qgmU4PNC-m1GIzgXrZuYKSdZ_wLJMXZgjpZzP0/rs:fit:860:0:0/g:ce/aHR0cHM6Ly90My5m/dGNkbi5uZXQvanBn/LzAxLzczLzk3Lzg4/LzM2MF9GXzE3Mzk3/ODgyMl8yM0FSVEJX/Q3MwMHhiRmRkckU0/SndBUmxVcWRpZWlP/WC5qcGc",
                "tokenName": "Turtlez",
                "tokenSymbol": "TRLZ",
                "players": [
                    {
                        "name": "Shelly Shane",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 2,
                            "throwingPower": 1,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Hardshell Hank",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Slider Sid",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Terrapin Tim",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": 2,
                            "defense": -1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Basker Barry",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Snapper Sam",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 0,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Reef Ralph",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": -1,
                            "piety": 1,
                            "speed": 2
                        }
                    },
                    {
                        "name": "Coral Cecil",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Digger Doug",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": -2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Mossback Max",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": -1,
                            "piety": 1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Sunny Steve",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Loggerhead Larry",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Ripple Rick",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 0,
                            "catching": 1,
                            "defense": -1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Scooter Scott",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Splasher Sean",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Chomper Chad",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    }
                ]
            },
            {
                "name": "Snailz",
                "logoUrl": "https://imgs.search.brave.com/ZOR-_-9QRxAHdLyD5QoIp34xv516vZGTolrDc1z-aC4/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9kMjlm/aHB3MDY5Y3R0Mi5j/bG91ZGZyb250Lm5l/dC9pY29uL2ltYWdl/LzEyMDE4MC9wcmV2/aWV3LnN2Zw.svg",
                "tokenName": "Snailz",
                "tokenSymbol": "SNLZ",
                "players": [
                    {
                        "name": "Shelly Sam",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Slimy Steve",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Spiral Sid",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 2,
                            "throwingAccuracy": -1,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": -2,
                            "piety": 2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Slugger Seth",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 1,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Slick Scott",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 1,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 0,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Shellback Sean",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 2,
                            "defense": -1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Silky Sandra",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Salty Sara",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Snail Pace Pat",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Snaily Sally",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Sandy Simon",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 0,
                            "defense": 1,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Slimeball Stan",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 0,
                            "piety": -1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Slithering Sophie",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -2
                        }
                    },
                    {
                        "name": "Speedy Stu",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 2,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Silent Sue",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": -2,
                            "throwingPower": 0,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Scaly Steve",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    }
                ]
            },
            {
                "name": "Anemonez",
                "logoUrl": "https://imgs.search.brave.com/YpB2meSALUOhh1k8Xuwwt7wJcULL7EFXvaRZzqNHMP4/rs:fit:860:0:0/g:ce/aHR0cHM6Ly9jZG4t/aWNvbnMtcG5nLmZs/YXRpY29uLmNvbS8x/MjgvNzU5MS83NTkx/MDAyLnBuZw",
                "tokenName": "Anemonez",
                "tokenSymbol": "ANEMZ",
                "players": [
                    {
                        "name": "Coral Carl",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": 1,
                            "throwingAccuracy": -1,
                            "throwingPower": 2,
                            "catching": 0,
                            "defense": 1,
                            "piety": -2,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Reef Rick",
                        "position": {
                            "pitcher": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": 2,
                            "defense": -2,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Barnacle Ben",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 1,
                            "catching": -1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Tidepool Tammy",
                        "position": {
                            "firstBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": -2,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Surfing Sam",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 2,
                            "throwingAccuracy": 1,
                            "throwingPower": -1,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Waverider Will",
                        "position": {
                            "secondBase": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 1,
                            "throwingPower": 2,
                            "catching": -2,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Kelpie Kyle",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": 0,
                            "throwingAccuracy": -2,
                            "throwingPower": 2,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Anemone Albert",
                        "position": {
                            "thirdBase": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 2,
                            "throwingAccuracy": 0,
                            "throwingPower": -2,
                            "catching": 1,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Sandy Steve",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -2,
                            "throwingAccuracy": 1,
                            "throwingPower": 0,
                            "catching": -1,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Diver Dan",
                        "position": {
                            "shortStop": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Marine Marcy",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": 0,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 1,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Seashell Sally",
                        "position": {
                            "leftField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -2,
                            "throwingAccuracy": 0,
                            "throwingPower": 2,
                            "catching": 1,
                            "defense": -1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Ocean Octavia",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            'mischief': null
                        },
                        "skills": {
                            "battingAccuracy": -1,
                            "battingPower": 0,
                            "throwingAccuracy": 1,
                            "throwingPower": -2,
                            "catching": 2,
                            "defense": 1,
                            "piety": -1,
                            "speed": 0
                        }
                    },
                    {
                        "name": "Current Christy",
                        "position": {
                            "centerField": null
                        },
                        "deity": {
                            "war": null
                        },
                        "skills": {
                            "battingAccuracy": 2,
                            "battingPower": -1,
                            "throwingAccuracy": -2,
                            "throwingPower": 1,
                            "catching": 0,
                            "defense": 1,
                            "piety": 0,
                            "speed": 1
                        }
                    },
                    {
                        "name": "Manta Ray Ray",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "indulgence": null
                        },
                        "skills": {
                            "battingAccuracy": -2,
                            "battingPower": 1,
                            "throwingAccuracy": 0,
                            "throwingPower": -1,
                            "catching": 2,
                            "defense": 1,
                            "piety": 0,
                            "speed": -1
                        }
                    },
                    {
                        "name": "Nautical Naomi",
                        "position": {
                            "rightField": null
                        },
                        "deity": {
                            "pestilence": null
                        },
                        "skills": {
                            "battingAccuracy": 1,
                            "battingPower": -1,
                            "throwingAccuracy": 2,
                            "throwingPower": 0,
                            "catching": -2,
                            "defense": 0,
                            "piety": 1,
                            "speed": 1
                        }
                    }
                ]
            }
        ]
    }
]