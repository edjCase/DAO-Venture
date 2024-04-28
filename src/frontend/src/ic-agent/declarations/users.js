export const idlFactory = ({ IDL }) => {
  const AddTeamOwnerRequest = IDL.Record({
    'votingPower' : IDL.Nat,
    'userId' : IDL.Principal,
    'teamId' : IDL.Nat,
  });
  const AddTeamOwnerResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'onOtherTeam' : IDL.Nat,
    'teamNotFound' : IDL.Null,
  });
  const AwardPointsRequest = IDL.Record({
    'userId' : IDL.Principal,
    'points' : IDL.Int,
  });
  const AwardPointsResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const TeamAssociationKind = IDL.Variant({
    'fan' : IDL.Null,
    'owner' : IDL.Record({ 'votingPower' : IDL.Nat }),
  });
  const User = IDL.Record({
    'id' : IDL.Principal,
    'team' : IDL.Opt(
      IDL.Record({ 'id' : IDL.Nat, 'kind' : TeamAssociationKind })
    ),
    'points' : IDL.Int,
  });
  const GetUserResult = IDL.Variant({
    'ok' : User,
    'notAuthorized' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const TeamStats = IDL.Record({
    'id' : IDL.Nat,
    'totalPoints' : IDL.Int,
    'ownerCount' : IDL.Nat,
    'userCount' : IDL.Nat,
  });
  const UserStats = IDL.Record({
    'teams' : IDL.Vec(TeamStats),
    'teamOwnerCount' : IDL.Nat,
    'totalPoints' : IDL.Int,
    'userCount' : IDL.Nat,
  });
  const GetStatsResult = IDL.Variant({ 'ok' : UserStats });
  const GetTeamOwnersRequest = IDL.Variant({
    'all' : IDL.Null,
    'team' : IDL.Nat,
  });
  const UserVotingInfo = IDL.Record({
    'id' : IDL.Principal,
    'votingPower' : IDL.Nat,
    'teamId' : IDL.Nat,
  });
  const GetTeamOwnersResult = IDL.Variant({ 'ok' : IDL.Vec(UserVotingInfo) });
  const GetUserLeaderboardRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const PagedResult = IDL.Record({
    'data' : IDL.Vec(User),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetUserLeaderboardResult = IDL.Variant({ 'ok' : PagedResult });
  const OnSeasonEndResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const SetUserFavoriteTeamResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadySet' : IDL.Null,
    'identityRequired' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  return IDL.Service({
    'addTeamOwner' : IDL.Func([AddTeamOwnerRequest], [AddTeamOwnerResult], []),
    'awardPoints' : IDL.Func(
        [IDL.Vec(AwardPointsRequest)],
        [AwardPointsResult],
        [],
      ),
    'get' : IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'getStats' : IDL.Func([], [GetStatsResult], ['query']),
    'getTeamOwners' : IDL.Func(
        [GetTeamOwnersRequest],
        [GetTeamOwnersResult],
        ['query'],
      ),
    'getUserLeaderboard' : IDL.Func(
        [GetUserLeaderboardRequest],
        [GetUserLeaderboardResult],
        ['query'],
      ),
    'onSeasonEnd' : IDL.Func([], [OnSeasonEndResult], []),
    'setFavoriteTeam' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [SetUserFavoriteTeamResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
