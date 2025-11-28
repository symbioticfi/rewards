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

// IDefaultOperatorRewardsMetaData contains all meta data concerning the IDefaultOperatorRewards contract.
var IDefaultOperatorRewardsMetaData = &bind.MetaData{
	ABI: "[{\"type\":\"function\",\"name\":\"NETWORK_MIDDLEWARE_SERVICE\",\"inputs\":[],\"outputs\":[{\"name\":\"\",\"type\":\"address\",\"internalType\":\"address\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"balance\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"claimRewards\",\"inputs\":[{\"name\":\"recipient\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"totalClaimable\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"proof\",\"type\":\"bytes32[]\",\"internalType\":\"bytes32[]\"}],\"outputs\":[{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"claimed\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"account\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"uint256\",\"internalType\":\"uint256\"}],\"stateMutability\":\"view\"},{\"type\":\"function\",\"name\":\"distributeRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"internalType\":\"uint256\"},{\"name\":\"root\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"outputs\":[],\"stateMutability\":\"nonpayable\"},{\"type\":\"function\",\"name\":\"root\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"internalType\":\"address\"}],\"outputs\":[{\"name\":\"\",\"type\":\"bytes32\",\"internalType\":\"bytes32\"}],\"stateMutability\":\"view\"},{\"type\":\"event\",\"name\":\"ClaimRewards\",\"inputs\":[{\"name\":\"recipient\",\"type\":\"address\",\"indexed\":false,\"internalType\":\"address\"},{\"name\":\"network\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"claimer\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"}],\"anonymous\":false},{\"type\":\"event\",\"name\":\"DistributeRewards\",\"inputs\":[{\"name\":\"network\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"token\",\"type\":\"address\",\"indexed\":true,\"internalType\":\"address\"},{\"name\":\"amount\",\"type\":\"uint256\",\"indexed\":false,\"internalType\":\"uint256\"},{\"name\":\"root\",\"type\":\"bytes32\",\"indexed\":false,\"internalType\":\"bytes32\"}],\"anonymous\":false},{\"type\":\"error\",\"name\":\"InsufficientBalance\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InsufficientTotalClaimable\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InsufficientTransfer\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"InvalidProof\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"NotNetworkMiddleware\",\"inputs\":[]},{\"type\":\"error\",\"name\":\"RootNotSet\",\"inputs\":[]}]",
}

// IDefaultOperatorRewardsABI is the input ABI used to generate the binding from.
// Deprecated: Use IDefaultOperatorRewardsMetaData.ABI instead.
var IDefaultOperatorRewardsABI = IDefaultOperatorRewardsMetaData.ABI

// IDefaultOperatorRewards is an auto generated Go binding around an Ethereum contract.
type IDefaultOperatorRewards struct {
	IDefaultOperatorRewardsCaller     // Read-only binding to the contract
	IDefaultOperatorRewardsTransactor // Write-only binding to the contract
	IDefaultOperatorRewardsFilterer   // Log filterer for contract events
}

// IDefaultOperatorRewardsCaller is an auto generated read-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultOperatorRewardsTransactor is an auto generated write-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultOperatorRewardsFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type IDefaultOperatorRewardsFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// IDefaultOperatorRewardsSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type IDefaultOperatorRewardsSession struct {
	Contract     *IDefaultOperatorRewards // Generic contract binding to set the session for
	CallOpts     bind.CallOpts            // Call options to use throughout this session
	TransactOpts bind.TransactOpts        // Transaction auth options to use throughout this session
}

// IDefaultOperatorRewardsCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type IDefaultOperatorRewardsCallerSession struct {
	Contract *IDefaultOperatorRewardsCaller // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts                  // Call options to use throughout this session
}

// IDefaultOperatorRewardsTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type IDefaultOperatorRewardsTransactorSession struct {
	Contract     *IDefaultOperatorRewardsTransactor // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts                  // Transaction auth options to use throughout this session
}

// IDefaultOperatorRewardsRaw is an auto generated low-level Go binding around an Ethereum contract.
type IDefaultOperatorRewardsRaw struct {
	Contract *IDefaultOperatorRewards // Generic contract binding to access the raw methods on
}

// IDefaultOperatorRewardsCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsCallerRaw struct {
	Contract *IDefaultOperatorRewardsCaller // Generic read-only contract binding to access the raw methods on
}

// IDefaultOperatorRewardsTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type IDefaultOperatorRewardsTransactorRaw struct {
	Contract *IDefaultOperatorRewardsTransactor // Generic write-only contract binding to access the raw methods on
}

// NewIDefaultOperatorRewards creates a new instance of IDefaultOperatorRewards, bound to a specific deployed contract.
func NewIDefaultOperatorRewards(address common.Address, backend bind.ContractBackend) (*IDefaultOperatorRewards, error) {
	contract, err := bindIDefaultOperatorRewards(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewards{IDefaultOperatorRewardsCaller: IDefaultOperatorRewardsCaller{contract: contract}, IDefaultOperatorRewardsTransactor: IDefaultOperatorRewardsTransactor{contract: contract}, IDefaultOperatorRewardsFilterer: IDefaultOperatorRewardsFilterer{contract: contract}}, nil
}

// NewIDefaultOperatorRewardsCaller creates a new read-only instance of IDefaultOperatorRewards, bound to a specific deployed contract.
func NewIDefaultOperatorRewardsCaller(address common.Address, caller bind.ContractCaller) (*IDefaultOperatorRewardsCaller, error) {
	contract, err := bindIDefaultOperatorRewards(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsCaller{contract: contract}, nil
}

// NewIDefaultOperatorRewardsTransactor creates a new write-only instance of IDefaultOperatorRewards, bound to a specific deployed contract.
func NewIDefaultOperatorRewardsTransactor(address common.Address, transactor bind.ContractTransactor) (*IDefaultOperatorRewardsTransactor, error) {
	contract, err := bindIDefaultOperatorRewards(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsTransactor{contract: contract}, nil
}

// NewIDefaultOperatorRewardsFilterer creates a new log filterer instance of IDefaultOperatorRewards, bound to a specific deployed contract.
func NewIDefaultOperatorRewardsFilterer(address common.Address, filterer bind.ContractFilterer) (*IDefaultOperatorRewardsFilterer, error) {
	contract, err := bindIDefaultOperatorRewards(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsFilterer{contract: contract}, nil
}

// bindIDefaultOperatorRewards binds a generic wrapper to an already deployed contract.
func bindIDefaultOperatorRewards(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := IDefaultOperatorRewardsMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultOperatorRewards.Contract.IDefaultOperatorRewardsCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.IDefaultOperatorRewardsTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.IDefaultOperatorRewardsTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _IDefaultOperatorRewards.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.contract.Transact(opts, method, params...)
}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCaller) NETWORKMIDDLEWARESERVICE(opts *bind.CallOpts) (common.Address, error) {
	var out []interface{}
	err := _IDefaultOperatorRewards.contract.Call(opts, &out, "NETWORK_MIDDLEWARE_SERVICE")

	if err != nil {
		return *new(common.Address), err
	}

	out0 := *abi.ConvertType(out[0], new(common.Address)).(*common.Address)

	return out0, err

}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsSession) NETWORKMIDDLEWARESERVICE() (common.Address, error) {
	return _IDefaultOperatorRewards.Contract.NETWORKMIDDLEWARESERVICE(&_IDefaultOperatorRewards.CallOpts)
}

// NETWORKMIDDLEWARESERVICE is a free data retrieval call binding the contract method 0x2c9d45b3.
//
// Solidity: function NETWORK_MIDDLEWARE_SERVICE() view returns(address)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCallerSession) NETWORKMIDDLEWARESERVICE() (common.Address, error) {
	return _IDefaultOperatorRewards.Contract.NETWORKMIDDLEWARESERVICE(&_IDefaultOperatorRewards.CallOpts)
}

// Balance is a free data retrieval call binding the contract method 0xb203bb99.
//
// Solidity: function balance(address network, address token) view returns(uint256)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCaller) Balance(opts *bind.CallOpts, network common.Address, token common.Address) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultOperatorRewards.contract.Call(opts, &out, "balance", network, token)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// Balance is a free data retrieval call binding the contract method 0xb203bb99.
//
// Solidity: function balance(address network, address token) view returns(uint256)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsSession) Balance(network common.Address, token common.Address) (*big.Int, error) {
	return _IDefaultOperatorRewards.Contract.Balance(&_IDefaultOperatorRewards.CallOpts, network, token)
}

// Balance is a free data retrieval call binding the contract method 0xb203bb99.
//
// Solidity: function balance(address network, address token) view returns(uint256)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCallerSession) Balance(network common.Address, token common.Address) (*big.Int, error) {
	return _IDefaultOperatorRewards.Contract.Balance(&_IDefaultOperatorRewards.CallOpts, network, token)
}

// Claimed is a free data retrieval call binding the contract method 0x1a5289a9.
//
// Solidity: function claimed(address network, address token, address account) view returns(uint256)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCaller) Claimed(opts *bind.CallOpts, network common.Address, token common.Address, account common.Address) (*big.Int, error) {
	var out []interface{}
	err := _IDefaultOperatorRewards.contract.Call(opts, &out, "claimed", network, token, account)

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// Claimed is a free data retrieval call binding the contract method 0x1a5289a9.
//
// Solidity: function claimed(address network, address token, address account) view returns(uint256)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsSession) Claimed(network common.Address, token common.Address, account common.Address) (*big.Int, error) {
	return _IDefaultOperatorRewards.Contract.Claimed(&_IDefaultOperatorRewards.CallOpts, network, token, account)
}

// Claimed is a free data retrieval call binding the contract method 0x1a5289a9.
//
// Solidity: function claimed(address network, address token, address account) view returns(uint256)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCallerSession) Claimed(network common.Address, token common.Address, account common.Address) (*big.Int, error) {
	return _IDefaultOperatorRewards.Contract.Claimed(&_IDefaultOperatorRewards.CallOpts, network, token, account)
}

// Root is a free data retrieval call binding the contract method 0xaadf2afe.
//
// Solidity: function root(address network, address token) view returns(bytes32)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCaller) Root(opts *bind.CallOpts, network common.Address, token common.Address) ([32]byte, error) {
	var out []interface{}
	err := _IDefaultOperatorRewards.contract.Call(opts, &out, "root", network, token)

	if err != nil {
		return *new([32]byte), err
	}

	out0 := *abi.ConvertType(out[0], new([32]byte)).(*[32]byte)

	return out0, err

}

// Root is a free data retrieval call binding the contract method 0xaadf2afe.
//
// Solidity: function root(address network, address token) view returns(bytes32)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsSession) Root(network common.Address, token common.Address) ([32]byte, error) {
	return _IDefaultOperatorRewards.Contract.Root(&_IDefaultOperatorRewards.CallOpts, network, token)
}

// Root is a free data retrieval call binding the contract method 0xaadf2afe.
//
// Solidity: function root(address network, address token) view returns(bytes32)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsCallerSession) Root(network common.Address, token common.Address) ([32]byte, error) {
	return _IDefaultOperatorRewards.Contract.Root(&_IDefaultOperatorRewards.CallOpts, network, token)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x315447db.
//
// Solidity: function claimRewards(address recipient, address network, address token, uint256 totalClaimable, bytes32[] proof) returns(uint256 amount)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsTransactor) ClaimRewards(opts *bind.TransactOpts, recipient common.Address, network common.Address, token common.Address, totalClaimable *big.Int, proof [][32]byte) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.contract.Transact(opts, "claimRewards", recipient, network, token, totalClaimable, proof)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x315447db.
//
// Solidity: function claimRewards(address recipient, address network, address token, uint256 totalClaimable, bytes32[] proof) returns(uint256 amount)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsSession) ClaimRewards(recipient common.Address, network common.Address, token common.Address, totalClaimable *big.Int, proof [][32]byte) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.ClaimRewards(&_IDefaultOperatorRewards.TransactOpts, recipient, network, token, totalClaimable, proof)
}

// ClaimRewards is a paid mutator transaction binding the contract method 0x315447db.
//
// Solidity: function claimRewards(address recipient, address network, address token, uint256 totalClaimable, bytes32[] proof) returns(uint256 amount)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsTransactorSession) ClaimRewards(recipient common.Address, network common.Address, token common.Address, totalClaimable *big.Int, proof [][32]byte) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.ClaimRewards(&_IDefaultOperatorRewards.TransactOpts, recipient, network, token, totalClaimable, proof)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x48a78da7.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes32 root) returns()
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsTransactor) DistributeRewards(opts *bind.TransactOpts, network common.Address, token common.Address, amount *big.Int, root [32]byte) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.contract.Transact(opts, "distributeRewards", network, token, amount, root)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x48a78da7.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes32 root) returns()
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsSession) DistributeRewards(network common.Address, token common.Address, amount *big.Int, root [32]byte) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.DistributeRewards(&_IDefaultOperatorRewards.TransactOpts, network, token, amount, root)
}

// DistributeRewards is a paid mutator transaction binding the contract method 0x48a78da7.
//
// Solidity: function distributeRewards(address network, address token, uint256 amount, bytes32 root) returns()
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsTransactorSession) DistributeRewards(network common.Address, token common.Address, amount *big.Int, root [32]byte) (*types.Transaction, error) {
	return _IDefaultOperatorRewards.Contract.DistributeRewards(&_IDefaultOperatorRewards.TransactOpts, network, token, amount, root)
}

// IDefaultOperatorRewardsClaimRewardsIterator is returned from FilterClaimRewards and is used to iterate over the raw logs and unpacked data for ClaimRewards events raised by the IDefaultOperatorRewards contract.
type IDefaultOperatorRewardsClaimRewardsIterator struct {
	Event *IDefaultOperatorRewardsClaimRewards // Event containing the contract specifics and raw log

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
func (it *IDefaultOperatorRewardsClaimRewardsIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultOperatorRewardsClaimRewards)
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
		it.Event = new(IDefaultOperatorRewardsClaimRewards)
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
func (it *IDefaultOperatorRewardsClaimRewardsIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultOperatorRewardsClaimRewardsIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultOperatorRewardsClaimRewards represents a ClaimRewards event raised by the IDefaultOperatorRewards contract.
type IDefaultOperatorRewardsClaimRewards struct {
	Recipient common.Address
	Network   common.Address
	Token     common.Address
	Claimer   common.Address
	Amount    *big.Int
	Raw       types.Log // Blockchain specific contextual infos
}

// FilterClaimRewards is a free log retrieval operation binding the contract event 0x28047ce71e7b959f6fc3946a1bdc43b003cd0b685630fe93725eb9eafee25826.
//
// Solidity: event ClaimRewards(address recipient, address indexed network, address indexed token, address indexed claimer, uint256 amount)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsFilterer) FilterClaimRewards(opts *bind.FilterOpts, network []common.Address, token []common.Address, claimer []common.Address) (*IDefaultOperatorRewardsClaimRewardsIterator, error) {

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

	logs, sub, err := _IDefaultOperatorRewards.contract.FilterLogs(opts, "ClaimRewards", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsClaimRewardsIterator{contract: _IDefaultOperatorRewards.contract, event: "ClaimRewards", logs: logs, sub: sub}, nil
}

// WatchClaimRewards is a free log subscription operation binding the contract event 0x28047ce71e7b959f6fc3946a1bdc43b003cd0b685630fe93725eb9eafee25826.
//
// Solidity: event ClaimRewards(address recipient, address indexed network, address indexed token, address indexed claimer, uint256 amount)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsFilterer) WatchClaimRewards(opts *bind.WatchOpts, sink chan<- *IDefaultOperatorRewardsClaimRewards, network []common.Address, token []common.Address, claimer []common.Address) (event.Subscription, error) {

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

	logs, sub, err := _IDefaultOperatorRewards.contract.WatchLogs(opts, "ClaimRewards", networkRule, tokenRule, claimerRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultOperatorRewardsClaimRewards)
				if err := _IDefaultOperatorRewards.contract.UnpackLog(event, "ClaimRewards", log); err != nil {
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

// ParseClaimRewards is a log parse operation binding the contract event 0x28047ce71e7b959f6fc3946a1bdc43b003cd0b685630fe93725eb9eafee25826.
//
// Solidity: event ClaimRewards(address recipient, address indexed network, address indexed token, address indexed claimer, uint256 amount)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsFilterer) ParseClaimRewards(log types.Log) (*IDefaultOperatorRewardsClaimRewards, error) {
	event := new(IDefaultOperatorRewardsClaimRewards)
	if err := _IDefaultOperatorRewards.contract.UnpackLog(event, "ClaimRewards", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}

// IDefaultOperatorRewardsDistributeRewardsIterator is returned from FilterDistributeRewards and is used to iterate over the raw logs and unpacked data for DistributeRewards events raised by the IDefaultOperatorRewards contract.
type IDefaultOperatorRewardsDistributeRewardsIterator struct {
	Event *IDefaultOperatorRewardsDistributeRewards // Event containing the contract specifics and raw log

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
func (it *IDefaultOperatorRewardsDistributeRewardsIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(IDefaultOperatorRewardsDistributeRewards)
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
		it.Event = new(IDefaultOperatorRewardsDistributeRewards)
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
func (it *IDefaultOperatorRewardsDistributeRewardsIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *IDefaultOperatorRewardsDistributeRewardsIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// IDefaultOperatorRewardsDistributeRewards represents a DistributeRewards event raised by the IDefaultOperatorRewards contract.
type IDefaultOperatorRewardsDistributeRewards struct {
	Network common.Address
	Token   common.Address
	Amount  *big.Int
	Root    [32]byte
	Raw     types.Log // Blockchain specific contextual infos
}

// FilterDistributeRewards is a free log retrieval operation binding the contract event 0x127e3b1db6c7a82e6a23205f7391ec1ebdef05836c0bbb2bdef8f60ba7920227.
//
// Solidity: event DistributeRewards(address indexed network, address indexed token, uint256 amount, bytes32 root)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsFilterer) FilterDistributeRewards(opts *bind.FilterOpts, network []common.Address, token []common.Address) (*IDefaultOperatorRewardsDistributeRewardsIterator, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _IDefaultOperatorRewards.contract.FilterLogs(opts, "DistributeRewards", networkRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return &IDefaultOperatorRewardsDistributeRewardsIterator{contract: _IDefaultOperatorRewards.contract, event: "DistributeRewards", logs: logs, sub: sub}, nil
}

// WatchDistributeRewards is a free log subscription operation binding the contract event 0x127e3b1db6c7a82e6a23205f7391ec1ebdef05836c0bbb2bdef8f60ba7920227.
//
// Solidity: event DistributeRewards(address indexed network, address indexed token, uint256 amount, bytes32 root)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsFilterer) WatchDistributeRewards(opts *bind.WatchOpts, sink chan<- *IDefaultOperatorRewardsDistributeRewards, network []common.Address, token []common.Address) (event.Subscription, error) {

	var networkRule []interface{}
	for _, networkItem := range network {
		networkRule = append(networkRule, networkItem)
	}
	var tokenRule []interface{}
	for _, tokenItem := range token {
		tokenRule = append(tokenRule, tokenItem)
	}

	logs, sub, err := _IDefaultOperatorRewards.contract.WatchLogs(opts, "DistributeRewards", networkRule, tokenRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(IDefaultOperatorRewardsDistributeRewards)
				if err := _IDefaultOperatorRewards.contract.UnpackLog(event, "DistributeRewards", log); err != nil {
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

// ParseDistributeRewards is a log parse operation binding the contract event 0x127e3b1db6c7a82e6a23205f7391ec1ebdef05836c0bbb2bdef8f60ba7920227.
//
// Solidity: event DistributeRewards(address indexed network, address indexed token, uint256 amount, bytes32 root)
func (_IDefaultOperatorRewards *IDefaultOperatorRewardsFilterer) ParseDistributeRewards(log types.Log) (*IDefaultOperatorRewardsDistributeRewards, error) {
	event := new(IDefaultOperatorRewardsDistributeRewards)
	if err := _IDefaultOperatorRewards.contract.UnpackLog(event, "DistributeRewards", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
