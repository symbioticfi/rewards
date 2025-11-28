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

// IDefaultOperatorRewardsFactoryMetaData contains all meta data concerning the IDefaultOperatorRewardsFactory contract.
var IDefaultOperatorRewardsFactoryMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"create\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"entity\",\"inputs\":[{\"name\":\"index\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"isEntity\",\"inputs\":[{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bool\",\"internalType\":\"bool\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"totalEntities\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"AddEntity\",\"inputs\":[{\"name\":\"entity\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"EntityNotExist\",\"inputs\":[]}]",
}

// IDefaultOperatorRewardsFactoryABI is the input ABI used to generate the binding from.
// Deprecated: Use IDefaultOperatorRewardsFactoryMetaData.ABI instead.
var IDefaultOperatorRewardsFactoryABI = IDefaultOperatorRewardsFactoryMetaData.ABI

// IDefaultOperatorRewardsFactory is an auto generated Go binding around an Ethereum contract.
type IDefaultOperatorRewardsFactory struct {
	IDefaultOperatorRewardsFactoryCaller     // Read-only binding to the contract
	IDefaultOperatorRewardsFactoryTransactor // Write-only binding to the contract
	IDefaultOperatorRewardsFactoryFilterer   // Log filterer for contract events
}

// IDefaultOperatorRewardsFactoryCaller is an auto generated read-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsFactoryCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultOperatorRewardsFactoryTransactor is an auto generated write-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsFactoryTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultOperatorRewardsFactoryFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type IDefaultOperatorRewardsFactoryFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultOperatorRewardsFactorySession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type IDefaultOperatorRewardsFactorySession struct {
	Contract     *IDefaultOperatorRewardsFactory // Generic contract binding to set the session for
	CallOpts     bind.CallOpts                   // Call options to use throughout this session
	TransactOpts bind.TransactOpts               // Transaction auth options to use throughout this session
}

// IDefaultOperatorRewardsFactoryCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type IDefaultOperatorRewardsFactoryCallerSession struct {
	Contract *IDefaultOperatorRewardsFactoryCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts                         // Call options to use throughout this session
}

// IDefaultOperatorRewardsFactoryTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type IDefaultOperatorRewardsFactoryTransactorSession struct {
	Contract     *IDefaultOperatorRewardsFactoryTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts                         // Transaction auth options to use throughout this session
}

// IDefaultOperatorRewardsFactoryRaw is an auto generated low-level Go binding around an Ethereum contract.
type IDefaultOperatorRewardsFactoryRaw struct {
	Contract *IDefaultOperatorRewardsFactory // Generic contract binding to access the raw methods on
}

// IDefaultOperatorRewardsFactoryCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsFactoryCallerRaw struct {
	Contract *IDefaultOperatorRewardsFactoryCaller // Generic read-only contract binding to access the raw methods on
}

// IDefaultOperatorRewardsFactoryTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsFactoryTransactorRaw struct {
	Contract *IDefaultOperatorRewardsFactoryTransactor // Generic write-only contract binding to access the raw methods on
}

// NewIDefaultOperatorRewardsFactory creates a new instance of IDefaultOperatorRewardsFactory, bound to a specific deployed contract.
func NewIDefaultOperatorRewardsFactory(address common.Address, backend bind.ContractBackend) (*IDefaultOperatorRewardsFactory, error) {
	contract, err := bindIDefaultOperatorRewardsFactory(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsFactory{IDefaultOperatorRewardsFactoryCaller: IDefaultOperatorRewardsFactoryCaller{contract: contract}, IDefaultOperatorRewardsFactoryTransactor: IDefaultOperatorRewardsFactoryTransactor{contract: contract}, IDefaultOperatorRewardsFactoryFilterer: IDefaultOperatorRewardsFactoryFilterer{contract: contract}}, nil
}

// NewIDefaultOperatorRewardsFactoryCaller creates a new read-only instance of IDefaultOperatorRewardsFactory, bound to a specific deployed contract.
func NewIDefaultOperatorRewardsFactoryCaller(address common.Address, caller bind.ContractCaller) (*IDefaultOperatorRewardsFactoryCaller, error) {
	contract, err := bindIDefaultOperatorRewardsFactory(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsFactoryCaller{contract: contract}, nil
}

// NewIDefaultOperatorRewardsFactoryTransactor creates a new write-only instance of IDefaultOperatorRewardsFactory, bound to a specific deployed contract.
func NewIDefaultOperatorRewardsFactoryTransactor(address common.Address, transactor bind.ContractTransactor) (*IDefaultOperatorRewardsFactoryTransactor, error) {
	contract, err := bindIDefaultOperatorRewardsFactory(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsFactoryTransactor{contract: contract}, nil
}

// NewIDefaultOperatorRewardsFactoryFilterer creates a new log filterer instance of IDefaultOperatorRewardsFactory, bound to a specific deployed contract.
func NewIDefaultOperatorRewardsFactoryFilterer(address common.Address, filterer bind.ContractFilterer) (*IDefaultOperatorRewardsFactoryFilterer, error) {
	contract, err := bindIDefaultOperatorRewardsFactory(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsFactoryFilterer{contract: contract}, nil
}

// bindIDefaultOperatorRewardsFactory binds a generic wrapper to an already deployed contract.
func bindIDefaultOperatorRewardsFactory(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := IDefaultOperatorRewardsFactoryMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultOperatorRewardsFactory.Contract.IDefaultOperatorRewardsFactoryCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultOperatorRewardsFactory.Contract.IDefaultOperatorRewardsFactoryTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultOperatorRewardsFactory.Contract.IDefaultOperatorRewardsFactoryTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultOperatorRewardsFactory.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultOperatorRewardsFactory.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultOperatorRewardsFactory.Contract.contract.Transact(opts, method, params...)
}

// Entity is a free data retrieval call binding the contract method 0xb42ba2a2.
//
// Solidity: function entity(uint256 index) view returns(address)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryCaller) Entity(opts *bind.CallOpts, index *big.Int) (common.Address, error) {
	var out []interface{}
	err := _IDefaultOperatorRewardsFactory.contract.Call(opts, &out, "entity", index)

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// Entity is a free data retrieval call binding the contract method 0xb42ba2a2.
//
// Solidity: function entity(uint256 index) view returns(address)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactorySession) Entity(index *big.Int) (common.Address, error) {
	return _IDefaultOperatorRewardsFactory.Contract.Entity(&_IDefaultOperatorRewardsFactory.CallOpts, index)
}

// Entity is a free data retrieval call binding the contract method 0xb42ba2a2.
//
// Solidity: function entity(uint256 index) view returns(address)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryCallerSession) Entity(index *big.Int) (common.Address, error) {
	return _IDefaultOperatorRewardsFactory.Contract.Entity(&_IDefaultOperatorRewardsFactory.CallOpts, index)
}

// IsEntity is a free data retrieval call binding the contract method 0x14887c58.
//
// Solidity: function isEntity(address account) view returns(bool)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryCaller) IsEntity(opts *bind.CallOpts, account common.Address) (bool, error) {
	var out []interface{}
	err := _IDefaultOperatorRewardsFactory.contract.Call(opts, &out, "isEntity", account)

	if err != nil {
		return *new(bool), err
	}

	out0 := *abi.ConvertType(out[0], new(bool)).(*bool)

	return out0, err

}

// IsEntity is a free data retrieval call binding the contract method 0x14887c58.
//
// Solidity: function isEntity(address account) view returns(bool)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactorySession) IsEntity(account common.Address) (bool, error) {
	return _IDefaultOperatorRewardsFactory.Contract.IsEntity(&_IDefaultOperatorRewardsFactory.CallOpts, account)
}

// IsEntity is a free data retrieval call binding the contract method 0x14887c58.
//
// Solidity: function isEntity(address account) view returns(bool)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryCallerSession) IsEntity(account common.Address) (bool, error) {
	return _IDefaultOperatorRewardsFactory.Contract.IsEntity(&_IDefaultOperatorRewardsFactory.CallOpts, account)
}

// TotalEntities is a free data retrieval call binding the contract method 0x5cd8b15e.
//
// Solidity: function totalEntities() view returns(uint256)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryCaller) TotalEntities(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultOperatorRewardsFactory.contract.Call(opts, &out, "totalEntities")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// TotalEntities is a free data retrieval call binding the contract method 0x5cd8b15e.
//
// Solidity: function totalEntities() view returns(uint256)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactorySession) TotalEntities() (*big.Int, error) {
	return _IDefaultOperatorRewardsFactory.Contract.TotalEntities(&_IDefaultOperatorRewardsFactory.CallOpts)
}

// TotalEntities is a free data retrieval call binding the contract method 0x5cd8b15e.
//
// Solidity: function totalEntities() view returns(uint256)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryCallerSession) TotalEntities() (*big.Int, error) {
	return _IDefaultOperatorRewardsFactory.Contract.TotalEntities(&_IDefaultOperatorRewardsFactory.CallOpts)
}

// Create is a paid mutator transaction binding the contract method 0xefc81a8c.
//
// Solidity: function create() returns(address)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryTransactor) Create(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultOperatorRewardsFactory.contract.Transact(opts, "create")
}

// Create is a paid mutator transaction binding the contract method 0xefc81a8c.
//
// Solidity: function create() returns(address)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactorySession) Create() (*types.Transaction, error) {
	return _IDefaultOperatorRewardsFactory.Contract.Create(&_IDefaultOperatorRewardsFactory.TransactOpts)
}

// Create is a paid mutator transaction binding the contract method 0xefc81a8c.
//
// Solidity: function create() returns(address)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryTransactorSession) Create() (*types.Transaction, error) {
	return _IDefaultOperatorRewardsFactory.Contract.Create(&_IDefaultOperatorRewardsFactory.TransactOpts)
}

// IDefaultOperatorRewardsFactoryAddEntityIterator is returned from FilterAddEntity and is used to iterate over the raw logs and unpacked data for AddEntity events raised by the IDefaultOperatorRewardsFactory contract.
type IDefaultOperatorRewardsFactoryAddEntityIterator struct {
	Event *IDefaultOperatorRewardsFactoryAddEntity // Event containing the contract specifics and raw log

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
func (it *IDefaultOperatorRewardsFactoryAddEntityIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultOperatorRewardsFactoryAddEntity)
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
		it.Event = new(IDefaultOperatorRewardsFactoryAddEntity)
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
func (it *IDefaultOperatorRewardsFactoryAddEntityIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultOperatorRewardsFactoryAddEntityIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultOperatorRewardsFactoryAddEntity represents a AddEntity event raised by the IDefaultOperatorRewardsFactory contract.
type IDefaultOperatorRewardsFactoryAddEntity struct {
	Entity common.Address
	Raw    types.Log // Blockchain specific contextual infos
}

// FilterAddEntity is a free log retrieval operation binding the contract event 0xb919910dcefbf753bfd926ab3b1d3f85d877190c3d01ba1bd585047b99b99f0b.
//
// Solidity: event AddEntity(address indexed entity)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryFilterer) FilterAddEntity(opts *bind.FilterOpts, entity []common.Address) (*IDefaultOperatorRewardsFactoryAddEntityIterator, error) {

	var entityRule []interface{}
	for _, entityItem := range entity {
		entityRule = append(entityRule, entityItem)
	}

	logs, sub, err := _IDefaultOperatorRewardsFactory.contract.FilterLogs(opts, "AddEntity", entityRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsFactoryAddEntityIterator{contract: _IDefaultOperatorRewardsFactory.contract, event: "AddEntity", logs: logs, sub: sub}, nil
}

// WatchAddEntity is a free log subscription operation binding the contract event 0xb919910dcefbf753bfd926ab3b1d3f85d877190c3d01ba1bd585047b99b99f0b.
//
// Solidity: event AddEntity(address indexed entity)
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryFilterer) WatchAddEntity(opts *bind.WatchOpts, sink chan<- *IDefaultOperatorRewardsFactoryAddEntity, entity []common.Address) (event.Subscription, error) {

	var entityRule []interface{}
	for _, entityItem := range entity {
		entityRule = append(entityRule, entityItem)
	}

	logs, sub, err := _IDefaultOperatorRewardsFactory.contract.WatchLogs(opts, "AddEntity", entityRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultOperatorRewardsFactoryAddEntity)
				if err := _IDefaultOperatorRewardsFactory.contract.UnpackLog(event, "AddEntity", log); err != nil {
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
func (_IDefaultOperatorRewardsFactory *IDefaultOperatorRewardsFactoryFilterer) ParseAddEntity(log types.Log) (*IDefaultOperatorRewardsFactoryAddEntity, error) {
	event := new(IDefaultOperatorRewardsFactoryAddEntity)
	if err := _IDefaultOperatorRewardsFactory.contract.UnpackLog(event, "AddEntity", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
