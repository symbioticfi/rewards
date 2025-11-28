using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;

namespace Symbiotic.Relay.IDefaultStakerRewardsFactory.abi.ContractDefinition
{
    public partial class InitParams : InitParamsBase { }

    public class InitParamsBase 
    {
        [Parameter("address", "vault", 1)]
        public virtual string Vault { get; set; }
        [Parameter("uint256", "adminFee", 2)]
        public virtual BigInteger AdminFee { get; set; }
        [Parameter("address", "defaultAdminRoleHolder", 3)]
        public virtual string DefaultAdminRoleHolder { get; set; }
        [Parameter("address", "adminFeeClaimRoleHolder", 4)]
        public virtual string AdminFeeClaimRoleHolder { get; set; }
        [Parameter("address", "adminFeeSetRoleHolder", 5)]
        public virtual string AdminFeeSetRoleHolder { get; set; }
    }
}
