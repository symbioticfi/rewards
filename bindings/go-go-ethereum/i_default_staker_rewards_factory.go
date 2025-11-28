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

// IDefaultStakerRewardsInitParams is an auto generated low-level Go binding around an user-defined struct.
type IDefaultStakerRewardsInitParams struct {
	Vault                   common.Address
	AdminFee                *big.Int
	DefaultAdminRoleHolder  common.Address
	AdminFeeClaimRoleHolder common.Address
	AdminFeeSetRoleHolder   common.Address
}

// IDefaultStakerRewardsFactoryMetaData contains all meta data concerning the IDefaultStakerRewardsFactory contract.
var IDefaultStakerRewardsFactoryMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"create\",\"inputs\":[{\"name\":\"params\",\"type\":\"tuple\",\"internalType\":\"structIDefaultStakerRewards.InitParams\",\"components\":[{\"name\":\"vault\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"adminFee\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"defaultAdminRoleHolder\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"adminFeeClaimRoleHolder\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"adminFeeSetRoleHolder\",\"type\":\"address\",\"internalType\":\"address\"}]}],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"entity\",\"inputs\":[{\"name\":\"index\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"isEntity\",\"inputs\":[{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"totalEntities\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"AddEntity\",\"inputs\":[{\"name\":\"entity\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"EntityNotExist\",\"inputs\":[]}]",
}

// IDefaultStakerRewardsFactoryABI is the input ABI used to generate the binding from.
// Deprecated: Use IDefaultStakerRewardsFactoryMetaData.ABI instead.
var IDefaultStakerRewardsFactoryABI = IDefaultStakerRewardsFactoryMetaData.ABI

// IDefaultStakerRewardsFactory is an auto generated Go binding around an Ethereum contract.
type IDefaultStakerRewardsFactory struct {
	IDefaultStakerRewardsFactoryCaller     // Read-only binding to the contract
	IDefaultStakerRewardsFactoryTransactor // Write-only binding to the contract
	IDefaultStakerRewardsFactoryFilterer   // Log filterer for contract events
}

// IDefaultStakerRewardsFactoryCaller is an auto generated read-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsFactoryCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultStakerRewardsFactoryTransactor is an auto generated write-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsFactoryTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultStakerRewardsFactoryFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type IDefaultStakerRewardsFactoryFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultStakerRewardsFactorySession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type IDefaultStakerRewardsFactorySession struct {
	Contract     *IDefaultStakerRewardsFactory // Generic contract binding to set the session for
	CallOpts     bind.CallOpts                 // Call options to use throughout this session
	TransactOpts bind.TransactOpts             // Transaction auth options to use throughout this session
}

// IDefaultStakerRewardsFactoryCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type IDefaultStakerRewardsFactoryCallerSession struct {
	Contract *IDefaultStakerRewardsFactoryCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts                       // Call options to use throughout this session
}

// IDefaultStakerRewardsFactoryTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type IDefaultStakerRewardsFactoryTransactorSession struct {
	Contract     *IDefaultStakerRewardsFactoryTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts                       // Transaction auth options to use throughout this session
}

// IDefaultStakerRewardsFactoryRaw is an auto generated low-level Go binding around an Ethereum contract.
type IDefaultStakerRewardsFactoryRaw struct {
	Contract *IDefaultStakerRewardsFactory // Generic contract binding to access the raw methods on
}

// IDefaultStakerRewardsFactoryCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsFactoryCallerRaw struct {
	Contract *IDefaultStakerRewardsFactoryCaller // Generic read-only contract binding to access the raw methods on
}

// IDefaultStakerRewardsFactoryTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type IDefaultStakerRewardsFactoryTransactorRaw struct {
	Contract *IDefaultStakerRewardsFactoryTransactor // Generic write-only contract binding to access the raw methods on
}

// NewIDefaultStakerRewardsFactory creates a new instance of IDefaultStakerRewardsFactory, bound to a specific deployed contract.
func NewIDefaultStakerRewardsFactory(address common.Address, backend bind.ContractBackend) (*IDefaultStakerRewardsFactory, error) {
	contract, err := bindIDefaultStakerRewardsFactory(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsFactory{IDefaultStakerRewardsFactoryCaller: IDefaultStakerRewardsFactoryCaller{contract: contract}, IDefaultStakerRewardsFactoryTransactor: IDefaultStakerRewardsFactoryTransactor{contract: contract}, IDefaultStakerRewardsFactoryFilterer: IDefaultStakerRewardsFactoryFilterer{contract: contract}}, nil
}

// NewIDefaultStakerRewardsFactoryCaller creates a new read-only instance of IDefaultStakerRewardsFactory, bound to a specific deployed contract.
func NewIDefaultStakerRewardsFactoryCaller(address common.Address, caller bind.ContractCaller) (*IDefaultStakerRewardsFactoryCaller, error) {
	contract, err := bindIDefaultStakerRewardsFactory(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsFactoryCaller{contract: contract}, nil
}

// NewIDefaultStakerRewardsFactoryTransactor creates a new write-only instance of IDefaultStakerRewardsFactory, bound to a specific deployed contract.
func NewIDefaultStakerRewardsFactoryTransactor(address common.Address, transactor bind.ContractTransactor) (*IDefaultStakerRewardsFactoryTransactor, error) {
	contract, err := bindIDefaultStakerRewardsFactory(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsFactoryTransactor{contract: contract}, nil
}

// NewIDefaultStakerRewardsFactoryFilterer creates a new log filterer instance of IDefaultStakerRewardsFactory, bound to a specific deployed contract.
func NewIDefaultStakerRewardsFactoryFilterer(address common.Address, filterer bind.ContractFilterer) (*IDefaultStakerRewardsFactoryFilterer, error) {
	contract, err := bindIDefaultStakerRewardsFactory(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsFactoryFilterer{contract: contract}, nil
}

// bindIDefaultStakerRewardsFactory binds a generic wrapper to an already deployed contract.
func bindIDefaultStakerRewardsFactory(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := IDefaultStakerRewardsFactoryMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultStakerRewardsFactory.Contract.IDefaultStakerRewardsFactoryCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultStakerRewardsFactory.Contract.IDefaultStakerRewardsFactoryTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultStakerRewardsFactory.Contract.IDefaultStakerRewardsFactoryTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultStakerRewardsFactory.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultStakerRewardsFactory.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultStakerRewardsFactory.Contract.contract.Transact(opts, method, params...)
}

// Entity is a free data retrieval call binding the contract method 0xb42ba2a2.
//
// Solidity: function entity(uint256 index) view returns(address)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryCaller) Entity(opts *bind.CallOpts, index *big.Int) (common.Address, error) {
	var out []interface{}
	err := _IDefaultStakerRewardsFactory.contract.Call(opts, &out, "entity", index)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Entity is a free data retrieval call binding the contract method 0xb42ba2a2.
//
// Solidity: function entity(uint256 index) view returns(address)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactorySession) Entity(index *big.Int) (common.Address, error) {
	return _IDefaultStakerRewardsFactory.Contract.Entity(&_IDefaultStakerRewardsFactory.CallOpts, index)
}

// Entity is a free data retrieval call binding the contract method 0xb42ba2a2.
//
// Solidity: function entity(uint256 index) view returns(address)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryCallerSession) Entity(index *big.Int) (common.Address, error) {
	return _IDefaultStakerRewardsFactory.Contract.Entity(&_IDefaultStakerRewardsFactory.CallOpts, index)
}

// IsEntity is a free data retrieval call binding the contract method 0x14887c58.
//
// Solidity: function isEntity(address account) view returns(bool)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryCaller) IsEntity(opts *bind.CallOpts, account common.Address) (bool, error) {
	var out []interface{}
	err := _IDefaultStakerRewardsFactory.contract.Call(opts, &out, "isEntity", account)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// IsEntity is a free data retrieval call binding the contract method 0x14887c58.
//
// Solidity: function isEntity(address account) view returns(bool)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactorySession) IsEntity(account common.Address) (bool, error) {
	return _IDefaultStakerRewardsFactory.Contract.IsEntity(&_IDefaultStakerRewardsFactory.CallOpts, account)
}

// IsEntity is a free data retrieval call binding the contract method 0x14887c58.
//
// Solidity: function isEntity(address account) view returns(bool)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryCallerSession) IsEntity(account common.Address) (bool, error) {
	return _IDefaultStakerRewardsFactory.Contract.IsEntity(&_IDefaultStakerRewardsFactory.CallOpts, account)
}

// TotalEntities is a free data retrieval call binding the contract method 0x5cd8b15e.
//
// Solidity: function totalEntities() view returns(uint256)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryCaller) TotalEntities(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultStakerRewardsFactory.contract.Call(opts, &out, "totalEntities")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// TotalEntities is a free data retrieval call binding the contract method 0x5cd8b15e.
//
// Solidity: function totalEntities() view returns(uint256)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactorySession) TotalEntities() (*big.Int, error) {
	return _IDefaultStakerRewardsFactory.Contract.TotalEntities(&_IDefaultStakerRewardsFactory.CallOpts)
}

// TotalEntities is a free data retrieval call binding the contract method 0x5cd8b15e.
//
// Solidity: function totalEntities() view returns(uint256)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryCallerSession) TotalEntities() (*big.Int, error) {
	return _IDefaultStakerRewardsFactory.Contract.TotalEntities(&_IDefaultStakerRewardsFactory.CallOpts)
}

// Create is a paid mutator transaction binding the contract method 0x61ca1df2.
//
// Solidity: function create((address,uint256,address,address,address) params) returns(address)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryTransactor) Create(opts *bind.TransactOpts, params IDefaultStakerRewardsInitParams) (*types.Transaction, error) {
	return _IDefaultStakerRewardsFactory.contract.Transact(opts, "create", params)
}

// Create is a paid mutator transaction binding the contract method 0x61ca1df2.
//
// Solidity: function create((address,uint256,address,address,address) params) returns(address)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactorySession) Create(params IDefaultStakerRewardsInitParams) (*types.Transaction, error) {
	return _IDefaultStakerRewardsFactory.Contract.Create(&_IDefaultStakerRewardsFactory.TransactOpts, params)
}

// Create is a paid mutator transaction binding the contract method 0x61ca1df2.
//
// Solidity: function create((address,uint256,address,address,address) params) returns(address)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryTransactorSession) Create(params IDefaultStakerRewardsInitParams) (*types.Transaction, error) {
	return _IDefaultStakerRewardsFactory.Contract.Create(&_IDefaultStakerRewardsFactory.TransactOpts, params)
}

// IDefaultStakerRewardsFactoryAddEntityIterator is returned from FilterAddEntity and is used to iterate over the raw logs and unpacked data for AddEntity events raised by the IDefaultStakerRewardsFactory contract.
type IDefaultStakerRewardsFactoryAddEntityIterator struct {
	Event *IDefaultStakerRewardsFactoryAddEntity // Event containing the contract specifics and raw log

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
func (it *IDefaultStakerRewardsFactoryAddEntityIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultStakerRewardsFactoryAddEntity)
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
		it.Event = new(IDefaultStakerRewardsFactoryAddEntity)
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
func (it *IDefaultStakerRewardsFactoryAddEntityIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultStakerRewardsFactoryAddEntityIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultStakerRewardsFactoryAddEntity represents a AddEntity event raised by the IDefaultStakerRewardsFactory contract.
type IDefaultStakerRewardsFactoryAddEntity struct {
	Entity common.Address
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterAddEntity is a free log retrieval operation binding the contract event 0xb919910dcefbf753bfd926ab3b1d3f85d877190c3d01ba1bd585047b99b99f0b.
//
// Solidity: event AddEntity(address indexed entity)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryFilterer) FilterAddEntity(opts *bind.FilterOpts, entity []common.Address) (*IDefaultStakerRewardsFactoryAddEntityIterator, error) {

	var entityRule []interface{}
	for _, entityItem := range entity {
		entityRule = append(entityRule, entityItem)
	}

	logs, sub, err := _IDefaultStakerRewardsFactory.contract.FilterLogs(opts, "AddEntity", entityRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultStakerRewardsFactoryAddEntityIterator{contract: _IDefaultStakerRewardsFactory.contract, event: "AddEntity", logs: logs, sub: sub}, nil
}

// WatchAddEntity is a free log subscription operation binding the contract event 0xb919910dcefbf753bfd926ab3b1d3f85d877190c3d01ba1bd585047b99b99f0b.
//
// Solidity: event AddEntity(address indexed entity)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryFilterer) WatchAddEntity(opts *bind.WatchOpts, sink chan<- *IDefaultStakerRewardsFactoryAddEntity, entity []common.Address) (event.Subscription, error) {

	var entityRule []interface{}
	for _, entityItem := range entity {
		entityRule = append(entityRule, entityItem)
	}

	logs, sub, err := _IDefaultStakerRewardsFactory.contract.WatchLogs(opts, "AddEntity", entityRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultStakerRewardsFactoryAddEntity)
				if err := _IDefaultStakerRewardsFactory.contract.UnpackLog(event, "AddEntity", log); err != nil {
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

// ParseAddEntity is a log parse operation binding the contract event 0xb919910dcefbf753bfd926ab3b1d3f85d877190c3d01ba1bd585047b99b99f0b.
//
// Solidity: event AddEntity(address indexed entity)
func (_IDefaultStakerRewardsFactory *IDefaultStakerRewardsFactoryFilterer) ParseAddEntity(log types.Log) (*IDefaultStakerRewardsFactoryAddEntity, error) {
	event := new(IDefaultStakerRewardsFactoryAddEntity)
	if err := _IDefaultStakerRewardsFactory.contract.UnpackLog(event, "AddEntity", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
