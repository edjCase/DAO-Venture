import Player "../Player";

actor class Team(name : Text) {
  stable var players : [Player.Player] = [];

  public query func getPlayers() : async [Player.Player] {
    return players;
  };
};
