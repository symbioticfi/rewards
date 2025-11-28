// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package relaycontracts

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// IDefaultStakerRewardsMetaData contains all meta data concerning the IDefaultStakerRewards contract.
var IDefaultStakerRewardsMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"ADMIN_FEE_BASE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"ADMIN_FEE_CLAIM_ROLE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"ADMIN_FEE_SET_ROLE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"NETWORK_MIDDLEWARE_SERVICE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"VAULT\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"VAULT_FACTORY\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"adminFee\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"claimAdminFee\",\"inputs\":[{\"name\":\"recipient\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"claimRewards\",\"inputs\":[{\"name\":\"recipient\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"claimable\",\"inputs\":[{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"claimableAdminFee\",\"inputs\":[{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"distributeRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"lastUnclaimedReward\",\"inputs\":[{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"rewards\",\"inputs\":[{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"rewardIndex\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"timestamp\",\"type\":\"uint48\",\"internalType\":\"uint48\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"rewardsLength\",\"inputs\":[{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"setAdminFee\",\"inputs\":[{\"name\":\"adminFee\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"version\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint64\",\"internalType\":\"uint64\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"ClaimAdminFee\",\"inputs\":[{\"name\":\"recipient\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ClaimRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"claimer\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"recipient\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"ClaimRewardsExtra\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"claimer\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"firstClaimedRewardIndex\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"rewardsClaimed\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"DistributeRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"distributeAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"adminFeeAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"timestamp\",\"type\":\"uint48\",\"indexed\":false,\"internalType\":\"uint48\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"InitVault\",\"inputs\":[{\"name\":\"vault\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"SetAdminFee\",\"inputs\":[{\"name\":\"adminFee\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"AlreadySet\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"HighAdminFee\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InsufficientAdminFee\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InsufficientReward\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidAdminFee\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidHintsLength\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidRecipient\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidRewardTimestamp\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"MissingRoles\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NoRewardsToClaim\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NotNetwork\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NotNetworkMiddleware\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NotVault\",\"inputs\":[]}]",
}

// IDefaultStakerRewardsABI is the input ABI used to generate the binding from.
// Deprecated: Use IDefaultStakerRewardsMetaData.ABI instead.
var IDefaultStakerRewardsABI = IDefaultStakerRewardsMetaData.ABI

// IDefaultStakerRewards is an auto generated Go binding around an Ethereum contract.
type IDefaultStakerRewards struct {
	IDefaultStakerRewardsCaller     // Read-only binding to the contract
	IDefaultStakerRewardsTransactor // Write-only binding to the contract
	IDefaultStakerRewardsFilterer   // Log filterer for contract events
}

// IDefaultStakerRewardsCaller is an auto generated read-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultStakerRewardsTransactor is an auto generated write-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultStakerRewardsFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type IDefaultStakerRewardsFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultStakerRewardsSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type IDefaultStakerRewardsSession struct {
	Contract     *IDefaultStakerRewards // Generic contract binding to set the session for
	CallOpts     bind.CallOpts          // Call options to use throughout this session
	TransactOpts bind.TransactOpts      // Transaction auth options to use throughout this session
}

// IDefaultStakerRewardsCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type IDefaultStakerRewardsCallerSession struct {
	Contract *IDefaultStakerRewardsCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts                // Call options to use throughout this session
}

// IDefaultStakerRewardsTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type IDefaultStakerRewardsTransactorSession struct {
	Contract     *IDefaultStakerRewardsTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts                // Transaction auth options to use throughout this session
}

// IDefaultStakerRewardsRaw is an auto generated low-level Go binding around an Ethereum contract.
type IDefaultStakerRewardsRaw struct {
	Contract *IDefaultStakerRewards // Generic contract binding to access the raw methods on
}

// IDefaultStakerRewardsCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsCallerRaw struct {
	Contract *IDefaultStakerRewardsCaller // Generic read-only contract binding to access the raw methods on
}

// IDefaultStakerRewardsTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsTransactorRaw struct {
	Contract *IDefaultStakerRewardsTransactor // Generic write-only contract binding to access the raw methods on
}

// NewIDefaultStakerRewards creates a new instance of IDefaultStakerRewards, bound to a specific deployed contract.
func NewIDefaultStakerRewards(address common.Address, backend bind.ContractBackend) (*IDefaultStakerRewards, error) {
	contract, err := bindIDefaultStakerRewards(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewards{IDefaultStakerRewardsCaller: IDefaultStakerRewardsCaller{contract: contract}, IDefaultStakerRewardsTransactor: IDefaultStakerRewardsTransactor{contract: contract}, IDefaultStakerRewardsFilterer: IDefaultStakerRewardsFilterer{contract: contract}}, nil
}

// NewIDefaultStakerRewardsCaller creates a new read-only instance of IDefaultStakerRewards, bound to a specific deployed contract.
func NewIDefaultStakerRewardsCaller(address common.Address, caller bind.ContractCaller) (*IDefaultStakerRewardsCaller, error) {
	contract, err := bindIDefaultStakerRewards(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsCaller{contract: contract}, nil
}

// NewIDefaultStakerRewardsTransactor creates a new write-only instance of IDefaultStakerRewards, bound to a specific deployed contract.
func NewIDefaultStakerRewardsTransactor(address common.Address, transactor bind.ContractTransactor) (*IDefaultStakerRewardsTransactor, error) {
	contract, err := bindIDefaultStakerRewards(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsTransactor{contract: contract}, nil
}

// NewIDefaultStakerRewardsFilterer creates a new log filterer instance of IDefaultStakerRewards, bound to a specific deployed contract.
func NewIDefaultStakerRewardsFilterer(address common.Address, filterer bind.ContractFilterer) (*IDefaultStakerRewardsFilterer, error) {
	contract, err := bindIDefaultStakerRewards(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsFilterer{contract: contract}, nil
}

// bindIDefaultStakerRewards binds a generic wrapper to an already deployed contract.
func bindIDefaultStakerRewards(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := IDefaultStakerRewardsMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultStakerRewards *IDefaultStakerRewardsRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultStakerRewards.Contract.IDefaultStakerRewardsCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultStakerRewards *IDefaultStakerRewardsRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.IDefaultStakerRewardsTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultStakerRewards *IDefaultStakerRewardsRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.IDefaultStakerRewardsTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultStakerRewards.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.contract.Transact(opts, method, params...)
}

// ADMINFEEBASE is a free data retrieval call binding the contract method 0xc00460ea.
//
// Solidity: function ADMIN_FEE_BASE() view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) ADMINFEEBASE(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "ADMIN_FEE_BASE")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// ADMINFEEBASE is a free data retrieval call binding the contract method 0xc00460ea.
//
// Solidity: function ADMIN_FEE_BASE() view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) ADMINFEEBASE() (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.ADMINFEEBASE(&_IDefaultStakerRewards.CallOpts)
}

// ADMINFEEBASE is a free data retrieval call binding the contract method 0xc00460ea.
//
// Solidity: function ADMIN_FEE_BASE() view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) ADMINFEEBASE() (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.ADMINFEEBASE(&_IDefaultStakerRewards.CallOpts)
}

// ADMINFEECLAIMROLE is a free data retrieval call binding the contract method 0xcb6ba75d.
//
// Solidity: function ADMIN_FEE_CLAIM_ROLE() view returns(bytes32)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) ADMINFEECLAIMROLE(opts *bind.CallOpts) ([32]byte, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "ADMIN_FEE_CLAIM_ROLE")

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// ADMINFEECLAIMROLE is a free data retrieval call binding the contract method 0xcb6ba75d.
//
// Solidity: function ADMIN_FEE_CLAIM_ROLE() view returns(bytes32)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) ADMINFEECLAIMROLE() ([32]byte, error) {
	return _IDefaultStakerRewards.Contract.ADMINFEECLAIMROLE(&_IDefaultStakerRewards.CallOpts)
}

// ADMINFEECLAIMROLE is a free data retrieval call binding the contract method 0xcb6ba75d.
//
// Solidity: function ADMIN_FEE_CLAIM_ROLE() view returns(bytes32)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) ADMINFEECLAIMROLE() ([32]byte, error) {
	return _IDefaultStakerRewards.Contract.ADMINFEECLAIMROLE(&_IDefaultStakerRewards.CallOpts)
}

// ADMINFEESETROLE is a free data retrieval call binding the contract method 0xa01fe38e.
//
// Solidity: function ADMIN_FEE_SET_ROLE() view returns(bytes32)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) ADMINFEESETROLE(opts *bind.CallOpts) ([32]byte, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "ADMIN_FEE_SET_ROLE")

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// ADMINFEESETROLE is a free data retrieval call binding the contract method 0xa01fe38e.
//
// Solidity: function ADMIN_FEE_SET_ROLE() view returns(bytes32)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) ADMINFEESETROLE() ([32]byte, error) {
	return _IDefaultStakerRewards.Contract.ADMINFEESETROLE(&_IDefaultStakerRewards.CallOpts)
}

// ADMINFEESETROLE is a free data retrieval call binding the contract method 0xa01fe38e.
//
// Solidity: function ADMIN_FEE_SET_ROLE() view returns(bytes32)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) ADMINFEESETROLE() ([32]byte, error) {
	return _IDefaultStakerRewards.Contract.ADMINFEESETROLE(&_IDefaultStakerRewards.CallOpts)
}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) NETWORKMIDDLEWARESERVICE(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "NETWORK_MIDDLEWARE_SERVICE")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) NETWORKMIDDLEWARESERVICE() (common.Address, error) {
	return _IDefaultStakerRewards.Contract.NETWORKMIDDLEWARESERVICE(&_IDefaultStakerRewards.CallOpts)
}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) NETWORKMIDDLEWARESERVICE() (common.Address, error) {
	return _IDefaultStakerRewards.Contract.NETWORKMIDDLEWARESERVICE(&_IDefaultStakerRewards.CallOpts)
}

// VAULT is a free data retrieval call binding the contract method 0x411557d1.
//
// Solidity: function VAULT() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) VAULT(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "VAULT")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// VAULT is a free data retrieval call binding the contract method 0x411557d1.
//
// Solidity: function VAULT() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) VAULT() (common.Address, error) {
	return _IDefaultStakerRewards.Contract.VAULT(&_IDefaultStakerRewards.CallOpts)
}

// VAULT is a free data retrieval call binding the contract method 0x411557d1.
//
// Solidity: function VAULT() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) VAULT() (common.Address, error) {
	return _IDefaultStakerRewards.Contract.VAULT(&_IDefaultStakerRewards.CallOpts)
}

// VAULTFACTORY is a free data retrieval call binding the contract method 0x103f2907.
//
// Solidity: function VAULT_FACTORY() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) VAULTFACTORY(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "VAULT_FACTORY")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// VAULTFACTORY is a free data retrieval call binding the contract method 0x103f2907.
//
// Solidity: function VAULT_FACTORY() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) VAULTFACTORY() (common.Address, error) {
	return _IDefaultStakerRewards.Contract.VAULTFACTORY(&_IDefaultStakerRewards.CallOpts)
}

// VAULTFACTORY is a free data retrieval call binding the contract method 0x103f2907.
//
// Solidity: function VAULT_FACTORY() view returns(address)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) VAULTFACTORY() (common.Address, error) {
	return _IDefaultStakerRewards.Contract.VAULTFACTORY(&_IDefaultStakerRewards.CallOpts)
}

// AdminFee is a free data retrieval call binding the contract method 0xa0be06f9.
//
// Solidity: function adminFee() view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) AdminFee(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "adminFee")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// AdminFee is a free data retrieval call binding the contract method 0xa0be06f9.
//
// Solidity: function adminFee() view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) AdminFee() (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.AdminFee(&_IDefaultStakerRewards.CallOpts)
}

// AdminFee is a free data retrieval call binding the contract method 0xa0be06f9.
//
// Solidity: function adminFee() view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) AdminFee() (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.AdminFee(&_IDefaultStakerRewards.CallOpts)
}

// Claimable is a free data retrieval call binding the contract method 0x76ee5656.
//
// Solidity: function claimable(address token, address account, bytes data) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) Claimable(opts *bind.CallOpts, token common.Address, account common.Address, data []byte) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "claimable", token, account, data)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// Claimable is a free data retrieval call binding the contract method 0x76ee5656.
//
// Solidity: function claimable(address token, address account, bytes data) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) Claimable(token common.Address, account common.Address, data []byte) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.Claimable(&_IDefaultStakerRewards.CallOpts, token, account, data)
}

// Claimable is a free data retrieval call binding the contract method 0x76ee5656.
//
// Solidity: function claimable(address token, address account, bytes data) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) Claimable(token common.Address, account common.Address, data []byte) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.Claimable(&_IDefaultStakerRewards.CallOpts, token, account, data)
}

// ClaimableAdminFee is a free data retrieval call binding the contract method 0x04fe4748.
//
// Solidity: function claimableAdminFee(address token) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) ClaimableAdminFee(opts *bind.CallOpts, token common.Address) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "claimableAdminFee", token)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// ClaimableAdminFee is a free data retrieval call binding the contract method 0x04fe4748.
//
// Solidity: function claimableAdminFee(address token) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) ClaimableAdminFee(token common.Address) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.ClaimableAdminFee(&_IDefaultStakerRewards.CallOpts, token)
}

// ClaimableAdminFee is a free data retrieval call binding the contract method 0x04fe4748.
//
// Solidity: function claimableAdminFee(address token) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) ClaimableAdminFee(token common.Address) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.ClaimableAdminFee(&_IDefaultStakerRewards.CallOpts, token)
}

// LastUnclaimedReward is a free data retrieval call binding the contract method 0x3f3be072.
//
// Solidity: function lastUnclaimedReward(address account, address token, address network) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) LastUnclaimedReward(opts *bind.CallOpts, account common.Address, token common.Address, network common.Address) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "lastUnclaimedReward", account, token, network)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// LastUnclaimedReward is a free data retrieval call binding the contract method 0x3f3be072.
//
// Solidity: function lastUnclaimedReward(address account, address token, address network) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) LastUnclaimedReward(account common.Address, token common.Address, network common.Address) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.LastUnclaimedReward(&_IDefaultStakerRewards.CallOpts, account, token, network)
}

// LastUnclaimedReward is a free data retrieval call binding the contract method 0x3f3be072.
//
// Solidity: function lastUnclaimedReward(address account, address token, address network) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) LastUnclaimedReward(account common.Address, token common.Address, network common.Address) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.LastUnclaimedReward(&_IDefaultStakerRewards.CallOpts, account, token, network)
}

// Rewards is a free data retrieval call binding the contract method 0x63497dc7.
//
// Solidity: function rewards(address token, address network, uint256 rewardIndex) view returns(uint256 amount, uint48 timestamp)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) Rewards(opts *bind.CallOpts, token common.Address, network common.Address, rewardIndex *big.Int) (struct {
	Amount    *big.Int
	Timestamp *big.Int
}, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "rewards", token, network, rewardIndex)

	outstruct := new(struct {
		Amount    *big.Int
		Timestamp *big.Int
	})
	if err != nil {
		return *outstruct, err
	}

	outstruct.Amount = *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)
	outstruct.Timestamp = *abi.ConvertType(out[1], new(*big.Int)).(**big.Int)

	return *outstruct, err

}

// Rewards is a free data retrieval call binding the contract method 0x63497dc7.
//
// Solidity: function rewards(address token, address network, uint256 rewardIndex) view returns(uint256 amount, uint48 timestamp)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) Rewards(token common.Address, network common.Address, rewardIndex *big.Int) (struct {
	Amount    *big.Int
	Timestamp *big.Int
}, error) {
	return _IDefaultStakerRewards.Contract.Rewards(&_IDefaultStakerRewards.CallOpts, token, network, rewardIndex)
}

// Rewards is a free data retrieval call binding the contract method 0x63497dc7.
//
// Solidity: function rewards(address token, address network, uint256 rewardIndex) view returns(uint256 amount, uint48 timestamp)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) Rewards(token common.Address, network common.Address, rewardIndex *big.Int) (struct {
	Amount    *big.Int
	Timestamp *big.Int
}, error) {
	return _IDefaultStakerRewards.Contract.Rewards(&_IDefaultStakerRewards.CallOpts, token, network, rewardIndex)
}

// RewardsLength is a free data retrieval call binding the contract method 0x9162aaa0.
//
// Solidity: function rewardsLength(address token, address network) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) RewardsLength(opts *bind.CallOpts, token common.Address, network common.Address) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "rewardsLength", token, network)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// RewardsLength is a free data retrieval call binding the contract method 0x9162aaa0.
//
// Solidity: function rewardsLength(address token, address network) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) RewardsLength(token common.Address, network common.Address) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.RewardsLength(&_IDefaultStakerRewards.CallOpts, token, network)
}

// RewardsLength is a free data retrieval call binding the contract method 0x9162aaa0.
//
// Solidity: function rewardsLength(address token, address network) view returns(uint256)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) RewardsLength(token common.Address, network common.Address) (*big.Int, error) {
	return _IDefaultStakerRewards.Contract.RewardsLength(&_IDefaultStakerRewards.CallOpts, token, network)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint64)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCaller) Version(opts *bind.CallOpts) (uint64, error) {
	var out []interface{}
	err := _IDefaultStakerRewards.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(uint64), err
	}

	out0 := *abi.ConvertType(out[0], new(uint64)).(*uint64)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint64)
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) Version() (uint64, error) {
	return _IDefaultStakerRewards.Contract.Version(&_IDefaultStakerRewards.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint64)
func (_IDefaultStakerRewards *IDefaultStakerRewardsCallerSession) Version() (uint64, error) {
	return _IDefaultStakerRewards.Contract.Version(&_IDefaultStakerRewards.CallOpts)
}

// ClaimAdminFee is a paid mutator transaction binding the contract method 0x7d1b56e5.
//
// Solidity: function claimAdminFee(address recipient, address token) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactor) ClaimAdminFee(opts *bind.TransactOpts, recipient common.Address, token common.Address) (*types.Transaction, error) {
	return _IDefaultStakerRewards.contract.Transact(opts, "claimAdminFee", recipient, token)
}

// ClaimAdminFee is a paid mutator transaction binding the contract method 0x7d1b56e5.
//
// Solidity: function claimAdminFee(address recipient, address token) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) ClaimAdminFee(recipient common.Address, token common.Address) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.ClaimAdminFee(&_IDefaultStakerRewards.TransactOpts, recipient, token)
}

// ClaimAdminFee is a paid mutator transaction binding the contract method 0x7d1b56e5.
//
// Solidity: function claimAdminFee(address recipient, address token) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactorSession) ClaimAdminFee(recipient common.Address, token common.Address) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.ClaimAdminFee(&_IDefaultStakerRewards.TransactOpts, recipient, token)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x5d0b5205.
//
// Solidity: function claimRewards(address recipient, address token, bytes data) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactor) ClaimRewards(opts *bind.TransactOpts, recipient common.Address, token common.Address, data []byte) (*types.Transaction, error) {
	return _IDefaultStakerRewards.contract.Transact(opts, "claimRewards", recipient, token, data)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x5d0b5205.
//
// Solidity: function claimRewards(address recipient, address token, bytes data) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) ClaimRewards(recipient common.Address, token common.Address, data []byte) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.ClaimRewards(&_IDefaultStakerRewards.TransactOpts, recipient, token, data)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x5d0b5205.
//
// Solidity: function claimRewards(address recipient, address token, bytes data) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactorSession) ClaimRewards(recipient common.Address, token common.Address, data []byte) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.ClaimRewards(&_IDefaultStakerRewards.TransactOpts, recipient, token, data)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x239723ed.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes data) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactor) DistributeRewards(opts *bind.TransactOpts, network common.Address, token common.Address, amount *big.Int, data []byte) (*types.Transaction, error) {
	return _IDefaultStakerRewards.contract.Transact(opts, "distributeRewards", network, token, amount, data)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x239723ed.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes data) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) DistributeRewards(network common.Address, token common.Address, amount *big.Int, data []byte) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.DistributeRewards(&_IDefaultStakerRewards.TransactOpts, network, token, amount, data)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x239723ed.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes data) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactorSession) DistributeRewards(network common.Address, token common.Address, amount *big.Int, data []byte) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.DistributeRewards(&_IDefaultStakerRewards.TransactOpts, network, token, amount, data)
}

// SetAdminFee is a paid mutator transaction binding the contract method 0x8beb60b6.
//
// Solidity: function setAdminFee(uint256 adminFee) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactor) SetAdminFee(opts *bind.TransactOpts, adminFee *big.Int) (*types.Transaction, error) {
	return _IDefaultStakerRewards.contract.Transact(opts, "setAdminFee", adminFee)
}

// SetAdminFee is a paid mutator transaction binding the contract method 0x8beb60b6.
//
// Solidity: function setAdminFee(uint256 adminFee) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsSession) SetAdminFee(adminFee *big.Int) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.SetAdminFee(&_IDefaultStakerRewards.TransactOpts, adminFee)
}

// SetAdminFee is a paid mutator transaction binding the contract method 0x8beb60b6.
//
// Solidity: function setAdminFee(uint256 adminFee) returns()
func (_IDefaultStakerRewards *IDefaultStakerRewardsTransactorSession) SetAdminFee(adminFee *big.Int) (*types.Transaction, error) {
	return _IDefaultStakerRewards.Contract.SetAdminFee(&_IDefaultStakerRewards.TransactOpts, adminFee)
}

// IDefaultStakerRewardsClaimAdminFeeIterator is returned from FilterClaimAdminFee and is used to iterate over the raw logs and unpacked data for ClaimAdminFee events raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsClaimAdminFeeIterator struct {
	Event *IDefaultStakerRewardsClaimAdminFee // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *IDefaultStakerRewardsClaimAdminFeeIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultStakerRewardsClaimAdminFee)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(IDefaultStakerRewardsClaimAdminFee)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *IDefaultStakerRewardsClaimAdminFeeIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultStakerRewardsClaimAdminFeeIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultStakerRewardsClaimAdminFee represents a ClaimAdminFee event raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsClaimAdminFee struct {
	Recipient common.Address
	Amount    *big.Int
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterClaimAdminFee is a free log retrieval operation binding the contract event 0x6059a38198b1dc42b3791087d1ff0fbd72b3179553c25f678cd246f52ffaaf59.
//
// Solidity: event ClaimAdminFee(address indexed recipient, uint256 amount)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) FilterClaimAdminFee(opts *bind.FilterOpts, recipient []common.Address) (*IDefaultStakerRewardsClaimAdminFeeIterator, error) {

	var recipientRule []interface{}
	for _, recipientItem := range recipient {
		recipientRule = append(recipientRule, recipientItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.FilterLogs(opts, "ClaimAdminFee", recipientRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsClaimAdminFeeIterator{contract: _IDefaultStakerRewards.contract, event: "ClaimAdminFee", logs: logs, sub: sub}, nil
}

// WatchClaimAdminFee is a free log subscription operation binding the contract event 0x6059a38198b1dc42b3791087d1ff0fbd72b3179553c25f678cd246f52ffaaf59.
//
// Solidity: event ClaimAdminFee(address indexed recipient, uint256 amount)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) WatchClaimAdminFee(opts *bind.WatchOpts, sink chan<- *IDefaultStakerRewardsClaimAdminFee, recipient []common.Address) (event.Subscription, error) {

	var recipientRule []interface{}
	for _, recipientItem := range recipient {
		recipientRule = append(recipientRule, recipientItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.WatchLogs(opts, "ClaimAdminFee", recipientRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultStakerRewardsClaimAdminFee)
				if err := _IDefaultStakerRewards.contract.UnpackLog(event, "ClaimAdminFee", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseClaimAdminFee is a log parse operation binding the contract event 0x6059a38198b1dc42b3791087d1ff0fbd72b3179553c25f678cd246f52ffaaf59.
//
// Solidity: event ClaimAdminFee(address indexed recipient, uint256 amount)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) ParseClaimAdminFee(log types.Log) (*IDefaultStakerRewardsClaimAdminFee, error) {
	event := new(IDefaultStakerRewardsClaimAdminFee)
	if err := _IDefaultStakerRewards.contract.UnpackLog(event, "ClaimAdminFee", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// IDefaultStakerRewardsClaimRewardsIterator is returned from FilterClaimRewards and is used to iterate over the raw logs and unpacked data for ClaimRewards events raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsClaimRewardsIterator struct {
	Event *IDefaultStakerRewardsClaimRewards // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *IDefaultStakerRewardsClaimRewardsIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultStakerRewardsClaimRewards)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(IDefaultStakerRewardsClaimRewards)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *IDefaultStakerRewardsClaimRewardsIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultStakerRewardsClaimRewardsIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultStakerRewardsClaimRewards represents a ClaimRewards event raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsClaimRewards struct {
	Network   common.Address
	Token     common.Address
	Claimer   common.Address
	Amount    *big.Int
	Recipient common.Address
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterClaimRewards is a free log retrieval operation binding the contract event 0x88744b3615a11586336358f196290c37189c924b0ce7f612d07789041af7cde4.
//
// Solidity: event ClaimRewards(address indexed network, address indexed token, address indexed claimer, uint256 amount, address recipient)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) FilterClaimRewards(opts *bind.FilterOpts, network []common.Address, token []common.Address, claimer []common.Address) (*IDefaultStakerRewardsClaimRewardsIterator, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}
	var claimerRule []interface{}
	for _, claimerItem := range claimer {
		claimerRule = append(claimerRule, claimerItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.FilterLogs(opts, "ClaimRewards", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsClaimRewardsIterator{contract: _IDefaultStakerRewards.contract, event: "ClaimRewards", logs: logs, sub: sub}, nil
}

// WatchClaimRewards is a free log subscription operation binding the contract event 0x88744b3615a11586336358f196290c37189c924b0ce7f612d07789041af7cde4.
//
// Solidity: event ClaimRewards(address indexed network, address indexed token, address indexed claimer, uint256 amount, address recipient)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) WatchClaimRewards(opts *bind.WatchOpts, sink chan<- *IDefaultStakerRewardsClaimRewards, network []common.Address, token []common.Address, claimer []common.Address) (event.Subscription, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}
	var claimerRule []interface{}
	for _, claimerItem := range claimer {
		claimerRule = append(claimerRule, claimerItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.WatchLogs(opts, "ClaimRewards", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultStakerRewardsClaimRewards)
				if err := _IDefaultStakerRewards.contract.UnpackLog(event, "ClaimRewards", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseClaimRewards is a log parse operation binding the contract event 0x88744b3615a11586336358f196290c37189c924b0ce7f612d07789041af7cde4.
//
// Solidity: event ClaimRewards(address indexed network, address indexed token, address indexed claimer, uint256 amount, address recipient)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) ParseClaimRewards(log types.Log) (*IDefaultStakerRewardsClaimRewards, error) {
	event := new(IDefaultStakerRewardsClaimRewards)
	if err := _IDefaultStakerRewards.contract.UnpackLog(event, "ClaimRewards", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// IDefaultStakerRewardsClaimRewardsExtraIterator is returned from FilterClaimRewardsExtra and is used to iterate over the raw logs and unpacked data for ClaimRewardsExtra events raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsClaimRewardsExtraIterator struct {
	Event *IDefaultStakerRewardsClaimRewardsExtra // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *IDefaultStakerRewardsClaimRewardsExtraIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultStakerRewardsClaimRewardsExtra)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(IDefaultStakerRewardsClaimRewardsExtra)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *IDefaultStakerRewardsClaimRewardsExtraIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultStakerRewardsClaimRewardsExtraIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultStakerRewardsClaimRewardsExtra represents a ClaimRewardsExtra event raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsClaimRewardsExtra struct {
	Network                 common.Address
	Token                   common.Address
	Claimer                 common.Address
	FirstClaimedRewardIndex *big.Int
	RewardsClaimed          *big.Int
	Raw                     types.Log // Blockchain specific contextual infos
}

// FilterClaimRewardsExtra is a free log retrieval operation binding the contract event 0xacd14cc0b0a59979040123e9ce2601bfc1ec40c1360bcc405e1ca188f17b7fc6.
//
// Solidity: event ClaimRewardsExtra(address indexed network, address indexed token, address indexed claimer, uint256 firstClaimedRewardIndex, uint256 rewardsClaimed)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) FilterClaimRewardsExtra(opts *bind.FilterOpts, network []common.Address, token []common.Address, claimer []common.Address) (*IDefaultStakerRewardsClaimRewardsExtraIterator, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}
	var claimerRule []interface{}
	for _, claimerItem := range claimer {
		claimerRule = append(claimerRule, claimerItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.FilterLogs(opts, "ClaimRewardsExtra", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsClaimRewardsExtraIterator{contract: _IDefaultStakerRewards.contract, event: "ClaimRewardsExtra", logs: logs, sub: sub}, nil
}

// WatchClaimRewardsExtra is a free log subscription operation binding the contract event 0xacd14cc0b0a59979040123e9ce2601bfc1ec40c1360bcc405e1ca188f17b7fc6.
//
// Solidity: event ClaimRewardsExtra(address indexed network, address indexed token, address indexed claimer, uint256 firstClaimedRewardIndex, uint256 rewardsClaimed)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) WatchClaimRewardsExtra(opts *bind.WatchOpts, sink chan<- *IDefaultStakerRewardsClaimRewardsExtra, network []common.Address, token []common.Address, claimer []common.Address) (event.Subscription, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}
	var claimerRule []interface{}
	for _, claimerItem := range claimer {
		claimerRule = append(claimerRule, claimerItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.WatchLogs(opts, "ClaimRewardsExtra", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultStakerRewardsClaimRewardsExtra)
				if err := _IDefaultStakerRewards.contract.UnpackLog(event, "ClaimRewardsExtra", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseClaimRewardsExtra is a log parse operation binding the contract event 0xacd14cc0b0a59979040123e9ce2601bfc1ec40c1360bcc405e1ca188f17b7fc6.
//
// Solidity: event ClaimRewardsExtra(address indexed network, address indexed token, address indexed claimer, uint256 firstClaimedRewardIndex, uint256 rewardsClaimed)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) ParseClaimRewardsExtra(log types.Log) (*IDefaultStakerRewardsClaimRewardsExtra, error) {
	event := new(IDefaultStakerRewardsClaimRewardsExtra)
	if err := _IDefaultStakerRewards.contract.UnpackLog(event, "ClaimRewardsExtra", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// IDefaultStakerRewardsDistributeRewardsIterator is returned from FilterDistributeRewards and is used to iterate over the raw logs and unpacked data for DistributeRewards events raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsDistributeRewardsIterator struct {
	Event *IDefaultStakerRewardsDistributeRewards // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *IDefaultStakerRewardsDistributeRewardsIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultStakerRewardsDistributeRewards)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(IDefaultStakerRewardsDistributeRewards)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *IDefaultStakerRewardsDistributeRewardsIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultStakerRewardsDistributeRewardsIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultStakerRewardsDistributeRewards represents a DistributeRewards event raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsDistributeRewards struct {
	Network          common.Address
	Token            common.Address
	DistributeAmount *big.Int
	AdminFeeAmount   *big.Int
	Timestamp        *big.Int
	Raw              types.Log // Blockchain specific contextual infos
}

// FilterDistributeRewards is a free log retrieval operation binding the contract event 0x52c39ebed294659631d22a2341c526a86ab683888dccb1429ac42c6e413d4b7b.
//
// Solidity: event DistributeRewards(address indexed network, address indexed token, uint256 distributeAmount, uint256 adminFeeAmount, uint48 timestamp)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) FilterDistributeRewards(opts *bind.FilterOpts, network []common.Address, token []common.Address) (*IDefaultStakerRewardsDistributeRewardsIterator, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.FilterLogs(opts, "DistributeRewards", networkRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsDistributeRewardsIterator{contract: _IDefaultStakerRewards.contract, event: "DistributeRewards", logs: logs, sub: sub}, nil
}

// WatchDistributeRewards is a free log subscription operation binding the contract event 0x52c39ebed294659631d22a2341c526a86ab683888dccb1429ac42c6e413d4b7b.
//
// Solidity: event DistributeRewards(address indexed network, address indexed token, uint256 distributeAmount, uint256 adminFeeAmount, uint48 timestamp)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) WatchDistributeRewards(opts *bind.WatchOpts, sink chan<- *IDefaultStakerRewardsDistributeRewards, network []common.Address, token []common.Address) (event.Subscription, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _IDefaultStakerRewards.contract.WatchLogs(opts, "DistributeRewards", networkRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultStakerRewardsDistributeRewards)
				if err := _IDefaultStakerRewards.contract.UnpackLog(event, "DistributeRewards", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseDistributeRewards is a log parse operation binding the contract event 0x52c39ebed294659631d22a2341c526a86ab683888dccb1429ac42c6e413d4b7b.
//
// Solidity: event DistributeRewards(address indexed network, address indexed token, uint256 distributeAmount, uint256 adminFeeAmount, uint48 timestamp)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) ParseDistributeRewards(log types.Log) (*IDefaultStakerRewardsDistributeRewards, error) {
	event := new(IDefaultStakerRewardsDistributeRewards)
	if err := _IDefaultStakerRewards.contract.UnpackLog(event, "DistributeRewards", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// IDefaultStakerRewardsInitVaultIterator is returned from FilterInitVault and is used to iterate over the raw logs and unpacked data for InitVault events raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsInitVaultIterator struct {
	Event *IDefaultStakerRewardsInitVault // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *IDefaultStakerRewardsInitVaultIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultStakerRewardsInitVault)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(IDefaultStakerRewardsInitVault)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *IDefaultStakerRewardsInitVaultIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultStakerRewardsInitVaultIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultStakerRewardsInitVault represents a InitVault event raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsInitVault struct {
	Vault common.Address
	Raw   types.Log // Blockchain specific contextual infos
}

// FilterInitVault is a free log retrieval operation binding the contract event 0x108cccaed2dfffe466544dfa3900b2fa5e707bb00ded59de6a950479b923216f.
//
// Solidity: event InitVault(address vault)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) FilterInitVault(opts *bind.FilterOpts) (*IDefaultStakerRewardsInitVaultIterator, error) {

	logs, sub, err := _IDefaultStakerRewards.contract.FilterLogs(opts, "InitVault")
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsInitVaultIterator{contract: _IDefaultStakerRewards.contract, event: "InitVault", logs: logs, sub: sub}, nil
}

// WatchInitVault is a free log subscription operation binding the contract event 0x108cccaed2dfffe466544dfa3900b2fa5e707bb00ded59de6a950479b923216f.
//
// Solidity: event InitVault(address vault)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) WatchInitVault(opts *bind.WatchOpts, sink chan<- *IDefaultStakerRewardsInitVault) (event.Subscription, error) {

	logs, sub, err := _IDefaultStakerRewards.contract.WatchLogs(opts, "InitVault")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultStakerRewardsInitVault)
				if err := _IDefaultStakerRewards.contract.UnpackLog(event, "InitVault", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseInitVault is a log parse operation binding the contract event 0x108cccaed2dfffe466544dfa3900b2fa5e707bb00ded59de6a950479b923216f.
//
// Solidity: event InitVault(address vault)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) ParseInitVault(log types.Log) (*IDefaultStakerRewardsInitVault, error) {
	event := new(IDefaultStakerRewardsInitVault)
	if err := _IDefaultStakerRewards.contract.UnpackLog(event, "InitVault", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// IDefaultStakerRewardsSetAdminFeeIterator is returned from FilterSetAdminFee and is used to iterate over the raw logs and unpacked data for SetAdminFee events raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsSetAdminFeeIterator struct {
	Event *IDefaultStakerRewardsSetAdminFee // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *IDefaultStakerRewardsSetAdminFeeIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultStakerRewardsSetAdminFee)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(IDefaultStakerRewardsSetAdminFee)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *IDefaultStakerRewardsSetAdminFeeIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultStakerRewardsSetAdminFeeIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultStakerRewardsSetAdminFee represents a SetAdminFee event raised by the IDefaultStakerRewards contract.
type IDefaultStakerRewardsSetAdminFee struct {
	AdminFee *big.Int
	Raw      types.Log // Blockchain specific contextual infos
}

// FilterSetAdminFee is a free log retrieval operation binding the contract event 0x2f0d0ace1d699b471d7b39522b5c8aae053bce1b422b7a4fe8f09bd6562a4b74.
//
// Solidity: event SetAdminFee(uint256 adminFee)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) FilterSetAdminFee(opts *bind.FilterOpts) (*IDefaultStakerRewardsSetAdminFeeIterator, error) {

	logs, sub, err := _IDefaultStakerRewards.contract.FilterLogs(opts, "SetAdminFee")
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsSetAdminFeeIterator{contract: _IDefaultStakerRewards.contract, event: "SetAdminFee", logs: logs, sub: sub}, nil
}

// WatchSetAdminFee is a free log subscription operation binding the contract event 0x2f0d0ace1d699b471d7b39522b5c8aae053bce1b422b7a4fe8f09bd6562a4b74.
//
// Solidity: event SetAdminFee(uint256 adminFee)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) WatchSetAdminFee(opts *bind.WatchOpts, sink chan<- *IDefaultStakerRewardsSetAdminFee) (event.Subscription, error) {

	logs, sub, err := _IDefaultStakerRewards.contract.WatchLogs(opts, "SetAdminFee")
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultStakerRewardsSetAdminFee)
				if err := _IDefaultStakerRewards.contract.UnpackLog(event, "SetAdminFee", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseSetAdminFee is a log parse operation binding the contract event 0x2f0d0ace1d699b471d7b39522b5c8aae053bce1b422b7a4fe8f09bd6562a4b74.
//
// Solidity: event SetAdminFee(uint256 adminFee)
func (_IDefaultStakerRewards *IDefaultStakerRewardsFilterer) ParseSetAdminFee(log types.Log) (*IDefaultStakerRewardsSetAdminFee, error) {
	event := new(IDefaultStakerRewardsSetAdminFee)
	if err := _IDefaultStakerRewards.contract.UnpackLog(event, "SetAdminFee", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
