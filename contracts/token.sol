pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract MyDeflationaryERC20Token is ERC20 {
    uint256 internal initial_amount;
    uint256[] supply_th; 
    uint8[] public perc_burnable_amount; 
    uint8 public idx_current_supply_th; 
    
    event DeflationUpdate(uint8 new_perc); 
    event Index(uint8 index); 
    
    constructor (
        string memory name,
        string memory symbol,
        uint8 _initial_amount, 
        uint256[] memory _supply_th,
        uint8[] memory _perc_burnable_amount
        ) ERC20(name, symbol) {
            require( _supply_th.length == _perc_burnable_amount.length, "Arrays Length" ); 
            supply_th = _supply_th;
            perc_burnable_amount = _perc_burnable_amount;             
            initial_amount = uint256(_initial_amount); 
            _mint(msg.sender, initial_amount);
            
            idx_current_supply_th = uint8(supply_th.length); 
            for(uint8 i=0; i<supply_th.length; ++i) {
                if( totalSupply() > supply_th[i] ) {
                    idx_current_supply_th = i;
                    break;
                }
            }
            emit Index(idx_current_supply_th); 
    }
    
    function check_update_inflation() public {
        if (idx_current_supply_th < perc_burnable_amount.length) {
            // Could happen a deflation switch 
            // Una tantum loop to recompute the new deflation perce 
            if( totalSupply() <= supply_th[idx_current_supply_th] ) {
                uint8 new_idx_current_supply_th = uint8(supply_th.length); 
                for( uint8 i=(idx_current_supply_th+1); i<supply_th.length; ++i ) {
                    if(totalSupply() > supply_th[i]) {
                        new_idx_current_supply_th = i; 
                        break; 
                    }
                }
                idx_current_supply_th = new_idx_current_supply_th; 
                emit DeflationUpdate(get_current_perc()); 
            }
        }
    }
    
    function get_current_perc() public returns (uint8) {
        check_update_inflation(); 
        return (idx_current_supply_th < perc_burnable_amount.length) ? perc_burnable_amount[idx_current_supply_th] : 0; 
    }
    
    // Compute the burnable amount 
    function _compute_burnable_amount(uint256 amount) internal returns (uint256) {
        check_update_inflation(); 
        uint256 temp = amount * uint256(get_current_perc()) / 100;
        return temp; 
    }
    
    
    // Burns a percentage of the tokens to be transferred and returns the actual amount to be transferred 
    function _partial_burn(uint256 amount) internal returns(uint256) {
        uint256 _burnable_amount = _compute_burnable_amount(amount);
        
        if(_burnable_amount > 0) {
            _burn(msg.sender, _burnable_amount );
        }
        
        return amount - _burnable_amount;
    }
    
    // Overriding transfer() to add the burnable amount
    function transfer(address to, uint256 amount) public override returns(bool) {
        return super.transfer(to, _partial_burn(amount));
    }
    
    // Overriding transferFrom() to add burnable amount 
    function transferFrom(address from, address to, uint256 amount) public override returns(bool) {
        return super.transferFrom(from, to, _partial_burn(amount)); 
    }
}

