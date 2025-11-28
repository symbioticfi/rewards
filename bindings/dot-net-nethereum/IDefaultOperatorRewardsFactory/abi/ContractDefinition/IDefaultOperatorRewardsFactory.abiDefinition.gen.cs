using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Numerics;
using Nethereum.Hex.HexTypes;
using Nethereum.ABI.FunctionEncoding.Attributes;
using Nethereum.RPC.Eth.DTOs;
using Nethereum.Contracts.CQS;
using Nethereum.Contracts;
using System.Threading;

namespace Symbiotic.Relay.IDefaultOperatorRewardsFactory.abi.ContractDefinition
{


    public partial class IDefaultOperatorRewardsFactory.abiDeployment : IDefaultOperatorRewardsFactory.abiDeploymentBase
    {
        public IDefaultOperatorRewardsFactory.abiDeployment() : base(BYTECODE) { }
        public IDefaultOperatorRewardsFactory.abiDeployment(string byteCode) : base(byteCode) { }
    }

    public class IDefaultOperatorRewardsFactory.abiDeploymentBase : ContractDeploymentMessage
    {
        public static string BYTECODE = "";
        public IDefaultOperatorRewardsFactory.abiDeploymentBase() : base(BYTECODE) { }
        public IDefaultOperatorRewardsFactory.abiDeploymentBase(string byteCode) : base(byteCode) { }

    }

    public partial class CreateFunction : CreateFunctionBase { }

    [Function("create", "address")]
    public class CreateFunctionBase : FunctionMessage
    {

    }

    public partial class EntityFunction : EntityFunctionBase { }

    [Function("entity", "address")]
    public class EntityFunctionBase : FunctionMessage
    {
        [Parameter("uint256", "index", 1)]
        public virtual BigInteger Index { get; set; }
    }

    public partial class IsEntityFunction : IsEntityFunctionBase { }

    [Function("isEntity", "bool")]
    public class IsEntityFunctionBase : FunctionMessage
    {
        [Parameter("address", "account", 1)]
        public virtual string Account { get; set; }
    }

    public partial class TotalEntitiesFunction : TotalEntitiesFunctionBase { }

    [Function("totalEntities", "uint256")]
    public class TotalEntitiesFunctionBase : FunctionMessage
    {

    }

    public partial class AddEntityEventDTO : AddEntityEventDTOBase { }

    [Event("AddEntity")]
    public class AddEntityEventDTOBase : IEventDTO
    {
        [Parameter("address", "entity", 1, true )]
        public virtual string Entity { get; set; }
    }

    public partial class EntityNotExistError : EntityNotExistErrorBase { }
    [Error("EntityNotExist")]
    public class EntityNotExistErrorBase : IErrorDTO
    {
    }



    public partial class EntityOutputDTO : EntityOutputDTOBase { }

    [FunctionOutput]
    public class EntityOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("address", "", 1)]
        public virtual string ReturnValue1 { get; set; }
    }

    public partial class IsEntityOutputDTO : IsEntityOutputDTOBase { }

    [FunctionOutput]
    public class IsEntityOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("bool", "", 1)]
        public virtual bool ReturnValue1 { get; set; }
    }

    public partial class TotalEntitiesOutputDTO : TotalEntitiesOutputDTOBase { }

    [FunctionOutput]
    public class TotalEntitiesOutputDTOBase : IFunctionOutputDTO 
    {
        [Parameter("uint256", "", 1)]
        public virtual BigInteger ReturnValue1 { get; set; }
    }
}
