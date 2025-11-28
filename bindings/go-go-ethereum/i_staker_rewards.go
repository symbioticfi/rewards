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

// IStakerRewardsMetaData contains all meta data concerning the IStakerRewards contract.
var IStakerRewardsMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"claimRewards\",\"inputs\":[{\"name\":\"recipient\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"claimable\",\"inputs\":[{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"distributeRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"data\",\"type\":\"bytes\",\"internalType\":\"bytes\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"version\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"uint64\",\"internalType\":\"uint64\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"ClaimRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"claimer\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"recipient\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"DistributeRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"distributeAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"adminFeeAmount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"timestamp\",\"type\":\"uint48\",\"indexed\":false,\"internalType\":\"uint48\"}],\"anonymous\":false}]",
}

// IStakerRewardsABI is the input ABI used to generate the binding from.
// Deprecated: Use IStakerRewardsMetaData.ABI instead.
var IStakerRewardsABI = IStakerRewardsMetaData.ABI

// IStakerRewards is an auto generated Go binding around an Ethereum contract.
type IStakerRewards struct {
	IStakerRewardsCaller     // Read-only binding to the contract
	IStakerRewardsTransactor // Write-only binding to the contract
	IStakerRewardsFilterer   // Log filterer for contract events
}

// IStakerRewardsCaller is an auto generated read-only Go binding around an Ethereum contract.
type IStakerRewardsCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IStakerRewardsTransactor is an auto generated write-only Go binding around an Ethereum contract.
type IStakerRewardsTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IStakerRewardsFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type IStakerRewardsFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IStakerRewardsSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type IStakerRewardsSession struct {
	Contract     *IStakerRewards   // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// IStakerRewardsCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type IStakerRewardsCallerSession struct {
	Contract *IStakerRewardsCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts         // Call options to use throughout this session
}

// IStakerRewardsTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type IStakerRewardsTransactorSession struct {
	Contract     *IStakerRewardsTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts         // Transaction auth options to use throughout this session
}

// IStakerRewardsRaw is an auto generated low-level Go binding around an Ethereum contract.
type IStakerRewardsRaw struct {
	Contract *IStakerRewards // Generic contract binding to access the raw methods on
}

// IStakerRewardsCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type IStakerRewardsCallerRaw struct {
	Contract *IStakerRewardsCaller // Generic read-only contract binding to access the raw methods on
}

// IStakerRewardsTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type IStakerRewardsTransactorRaw struct {
	Contract *IStakerRewardsTransactor // Generic write-only contract binding to access the raw methods on
}

// NewIStakerRewards creates a new instance of IStakerRewards, bound to a specific deployed contract.
func NewIStakerRewards(address common.Address, backend bind.ContractBackend) (*IStakerRewards, error) {
	contract, err := bindIStakerRewards(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &IStakerRewards{IStakerRewardsCaller: IStakerRewardsCaller{contract: contract}, IStakerRewardsTransactor: IStakerRewardsTransactor{contract: contract}, IStakerRewardsFilterer: IStakerRewardsFilterer{contract: contract}}, nil
}

// NewIStakerRewardsCaller creates a new read-only instance of IStakerRewards, bound to a specific deployed contract.
func NewIStakerRewardsCaller(address common.Address, caller bind.ContractCaller) (*IStakerRewardsCaller, error) {
	contract, err := bindIStakerRewards(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &IStakerRewardsCaller{contract: contract}, nil
}

// NewIStakerRewardsTransactor creates a new write-only instance of IStakerRewards, bound to a specific deployed contract.
func NewIStakerRewardsTransactor(address common.Address, transactor bind.ContractTransactor) (*IStakerRewardsTransactor, error) {
	contract, err := bindIStakerRewards(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &IStakerRewardsTransactor{contract: contract}, nil
}

// NewIStakerRewardsFilterer creates a new log filterer instance of IStakerRewards, bound to a specific deployed contract.
func NewIStakerRewardsFilterer(address common.Address, filterer bind.ContractFilterer) (*IStakerRewardsFilterer, error) {
	contract, err := bindIStakerRewards(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &IStakerRewardsFilterer{contract: contract}, nil
}

// bindIStakerRewards binds a generic wrapper to an already deployed contract.
func bindIStakerRewards(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := IStakerRewardsMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IStakerRewards *IStakerRewardsRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IStakerRewards.Contract.IStakerRewardsCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IStakerRewards *IStakerRewardsRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IStakerRewards.Contract.IStakerRewardsTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IStakerRewards *IStakerRewardsRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IStakerRewards.Contract.IStakerRewardsTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IStakerRewards *IStakerRewardsCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IStakerRewards.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IStakerRewards *IStakerRewardsTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IStakerRewards.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IStakerRewards *IStakerRewardsTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IStakerRewards.Contract.contract.Transact(opts, method, params...)
}

// Claimable is a free data retrieval call binding the contract method 0x76ee5656.
//
// Solidity: function claimable(address token, address account, bytes data) view returns(uint256)
func (_IStakerRewards *IStakerRewardsCaller) Claimable(opts *bind.CallOpts, token common.Address, account common.Address, data []byte) (*big.Int, error) {
	var out []interface{}
	err := _IStakerRewards.contract.Call(opts, &out, "claimable", token, account, data)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// Claimable is a free data retrieval call binding the contract method 0x76ee5656.
//
// Solidity: function claimable(address token, address account, bytes data) view returns(uint256)
func (_IStakerRewards *IStakerRewardsSession) Claimable(token common.Address, account common.Address, data []byte) (*big.Int, error) {
	return _IStakerRewards.Contract.Claimable(&_IStakerRewards.CallOpts, token, account, data)
}

// Claimable is a free data retrieval call binding the contract method 0x76ee5656.
//
// Solidity: function claimable(address token, address account, bytes data) view returns(uint256)
func (_IStakerRewards *IStakerRewardsCallerSession) Claimable(token common.Address, account common.Address, data []byte) (*big.Int, error) {
	return _IStakerRewards.Contract.Claimable(&_IStakerRewards.CallOpts, token, account, data)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint64)
func (_IStakerRewards *IStakerRewardsCaller) Version(opts *bind.CallOpts) (uint64, error) {
	var out []interface{}
	err := _IStakerRewards.contract.Call(opts, &out, "version")

	if err != nil {
		return *new(uint64), err
	}

	out0 := *abi.ConvertType(out[0], new(uint64)).(*uint64)

	return out0, err

}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint64)
func (_IStakerRewards *IStakerRewardsSession) Version() (uint64, error) {
	return _IStakerRewards.Contract.Version(&_IStakerRewards.CallOpts)
}

// Version is a free data retrieval call binding the contract method 0x54fd4d50.
//
// Solidity: function version() view returns(uint64)
func (_IStakerRewards *IStakerRewardsCallerSession) Version() (uint64, error) {
	return _IStakerRewards.Contract.Version(&_IStakerRewards.CallOpts)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x5d0b5205.
//
// Solidity: function claimRewards(address recipient, address token, bytes data) returns()
func (_IStakerRewards *IStakerRewardsTransactor) ClaimRewards(opts *bind.TransactOpts, recipient common.Address, token common.Address, data []byte) (*types.Transaction, error) {
	return _IStakerRewards.contract.Transact(opts, "claimRewards", recipient, token, data)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x5d0b5205.
//
// Solidity: function claimRewards(address recipient, address token, bytes data) returns()
func (_IStakerRewards *IStakerRewardsSession) ClaimRewards(recipient common.Address, token common.Address, data []byte) (*types.Transaction, error) {
	return _IStakerRewards.Contract.ClaimRewards(&_IStakerRewards.TransactOpts, recipient, token, data)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x5d0b5205.
//
// Solidity: function claimRewards(address recipient, address token, bytes data) returns()
func (_IStakerRewards *IStakerRewardsTransactorSession) ClaimRewards(recipient common.Address, token common.Address, data []byte) (*types.Transaction, error) {
	return _IStakerRewards.Contract.ClaimRewards(&_IStakerRewards.TransactOpts, recipient, token, data)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x239723ed.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes data) returns()
func (_IStakerRewards *IStakerRewardsTransactor) DistributeRewards(opts *bind.TransactOpts, network common.Address, token common.Address, amount *big.Int, data []byte) (*types.Transaction, error) {
	return _IStakerRewards.contract.Transact(opts, "distributeRewards", network, token, amount, data)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x239723ed.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes data) returns()
func (_IStakerRewards *IStakerRewardsSession) DistributeRewards(network common.Address, token common.Address, amount *big.Int, data []byte) (*types.Transaction, error) {
	return _IStakerRewards.Contract.DistributeRewards(&_IStakerRewards.TransactOpts, network, token, amount, data)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x239723ed.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes data) returns()
func (_IStakerRewards *IStakerRewardsTransactorSession) DistributeRewards(network common.Address, token common.Address, amount *big.Int, data []byte) (*types.Transaction, error) {
	return _IStakerRewards.Contract.DistributeRewards(&_IStakerRewards.TransactOpts, network, token, amount, data)
}

// IStakerRewardsClaimRewardsIterator is returned from FilterClaimRewards and is used to iterate over the raw logs and unpacked data for ClaimRewards events raised by the IStakerRewards contract.
type IStakerRewardsClaimRewardsIterator struct {
	Event *IStakerRewardsClaimRewards // Event containing the contract specifics and raw log

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
func (it *IStakerRewardsClaimRewardsIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IStakerRewardsClaimRewards)
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
		it.Event = new(IStakerRewardsClaimRewards)
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
func (it *IStakerRewardsClaimRewardsIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IStakerRewardsClaimRewardsIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IStakerRewardsClaimRewards represents a ClaimRewards event raised by the IStakerRewards contract.
type IStakerRewardsClaimRewards struct {
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
func (_IStakerRewards *IStakerRewardsFilterer) FilterClaimRewards(opts *bind.FilterOpts, network []common.Address, token []common.Address, claimer []common.Address) (*IStakerRewardsClaimRewardsIterator, error) {

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

	logs, sub, err := _IStakerRewards.contract.FilterLogs(opts, "ClaimRewards", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return &IStakerRewardsClaimRewardsIterator{contract: _IStakerRewards.contract, event: "ClaimRewards", logs: logs, sub: sub}, nil
}

// WatchClaimRewards is a free log subscription operation binding the contract event 0x88744b3615a11586336358f196290c37189c924b0ce7f612d07789041af7cde4.
//
// Solidity: event ClaimRewards(address indexed network, address indexed token, address indexed claimer, uint256 amount, address recipient)
func (_IStakerRewards *IStakerRewardsFilterer) WatchClaimRewards(opts *bind.WatchOpts, sink chan<- *IStakerRewardsClaimRewards, network []common.Address, token []common.Address, claimer []common.Address) (event.Subscription, error) {

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

	logs, sub, err := _IStakerRewards.contract.WatchLogs(opts, "ClaimRewards", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IStakerRewardsClaimRewards)
				if err := _IStakerRewards.contract.UnpackLog(event, "ClaimRewards", log); err != nil {
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
func (_IStakerRewards *IStakerRewardsFilterer) ParseClaimRewards(log types.Log) (*IStakerRewardsClaimRewards, error) {
	event := new(IStakerRewardsClaimRewards)
	if err := _IStakerRewards.contract.UnpackLog(event, "ClaimRewards", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// IStakerRewardsDistributeRewardsIterator is returned from FilterDistributeRewards and is used to iterate over the raw logs and unpacked data for DistributeRewards events raised by the IStakerRewards contract.
type IStakerRewardsDistributeRewardsIterator struct {
	Event *IStakerRewardsDistributeRewards // Event containing the contract specifics and raw log

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
func (it *IStakerRewardsDistributeRewardsIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IStakerRewardsDistributeRewards)
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
		it.Event = new(IStakerRewardsDistributeRewards)
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
func (it *IStakerRewardsDistributeRewardsIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IStakerRewardsDistributeRewardsIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IStakerRewardsDistributeRewards represents a DistributeRewards event raised by the IStakerRewards contract.
type IStakerRewardsDistributeRewards struct {
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
func (_IStakerRewards *IStakerRewardsFilterer) FilterDistributeRewards(opts *bind.FilterOpts, network []common.Address, token []common.Address) (*IStakerRewardsDistributeRewardsIterator, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _IStakerRewards.contract.FilterLogs(opts, "DistributeRewards", networkRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return &IStakerRewardsDistributeRewardsIterator{contract: _IStakerRewards.contract, event: "DistributeRewards", logs: logs, sub: sub}, nil
}

// WatchDistributeRewards is a free log subscription operation binding the contract event 0x52c39ebed294659631d22a2341c526a86ab683888dccb1429ac42c6e413d4b7b.
//
// Solidity: event DistributeRewards(address indexed network, address indexed token, uint256 distributeAmount, uint256 adminFeeAmount, uint48 timestamp)
func (_IStakerRewards *IStakerRewardsFilterer) WatchDistributeRewards(opts *bind.WatchOpts, sink chan<- *IStakerRewardsDistributeRewards, network []common.Address, token []common.Address) (event.Subscription, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _IStakerRewards.contract.WatchLogs(opts, "DistributeRewards", networkRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IStakerRewardsDistributeRewards)
				if err := _IStakerRewards.contract.UnpackLog(event, "DistributeRewards", log); err != nil {
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
func (_IStakerRewards *IStakerRewardsFilterer) ParseDistributeRewards(log types.Log) (*IStakerRewardsDistributeRewards, error) {
	event := new(IStakerRewardsDistributeRewards)
	if err := _IStakerRewards.contract.UnpackLog(event, "DistributeRewards", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
