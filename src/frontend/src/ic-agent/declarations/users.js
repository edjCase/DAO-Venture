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
  const GetTeamOwnersRequest = IDL.Variant({
    'all' : IDL.Null,
    'team' : IDL.Nat,
  });
  const UserVotingInfo = IDL.Record({
    'id' : IDL.Principal,
    'votingPower' : IDL.Nat,
  });
  const GetTeamOwnersResult = IDL.Variant({ 'ok' : IDL.Vec(UserVotingInfo) });
  const OnSeasonCompleteResult = IDL.Variant({
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
    'getAll' : IDL.Func([], [IDL.Vec(User)], ['query']),
    'getTeamOwners' : IDL.Func(
        [GetTeamOwnersRequest],
        [GetTeamOwnersResult],
        ['query'],
      ),
    'onSeasonComplete' : IDL.Func([], [OnSeasonCompleteResult], []),
    'setFavoriteTeam' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [SetUserFavoriteTeamResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
