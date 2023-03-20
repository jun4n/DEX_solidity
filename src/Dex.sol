// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
/*
CPMM (xy=k) 방식의 AMM을 사용하는 DEX를 구현하세요.
Swap : Pool 생성 시 지정된 두 종류의 토큰을 서로 교환할 수 있어야 합니다. Input 토큰과 Input 수량, 최소 Output 요구량을 받아서 Output 토큰으로 바꿔주고 최소 요구량에 미달할 경우 revert 해야합니다. 수수료는 0.1%로 하세요.
Add / Remove Liquidity : ERC-20 기반 LP 토큰을 사용해야 합니다. 수수료 수입과 Pool에 기부된 금액을 제외하고는 더 많은 토큰을 회수할 수 있는 취약점이 없어야 합니다. Concentrated Liquidity는 필요 없습니다.

 */
import "../lib/forge-std/src/console.sol";
contract Dex is  ERC20{
    address private owner;
    address public token_x;
    address public token_y;
    uint public reserve_x;
    uint public reserve_y;
    uint public price_x;
    uint public price_y;
    uint public token_liquidity_L;

    function sqrt(uint y) public returns(uint z){
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
    constructor (address tokenX, address tokenY) ERC20("DRM", "DREAM_TOKEN"){
        require(tokenX != tokenY, "same token x, y");
        require(address(tokenX) != address(0) && address(tokenY) != address(0), "zero address token x or y");
        owner = msg.sender;
        token_x = tokenX;
        token_y = tokenY;
        //token_LP = new LP_ERC20("DRM","DREAM_TOKEN");
    }
    function addLiquidity(uint256 tokenXAmount, uint256 tokenYAmount, uint256 minimumLPTokenAmount) external returns (uint256 LPTokenAmount){
        require(totalSupply() == 0 || tokenXAmount / tokenYAmount == reserve_x / reserve_y, "");
        // 유동성 전달받는 과정
        bool success = ERC20(token_x).transferFrom(msg.sender, address(this), tokenXAmount);
        require(success, "token x transferFrom failed");
        success = ERC20(token_y).transferFrom(msg.sender, address(this), tokenYAmount);
        require(success, "token y transferFrom failed");
        reserve_x += tokenXAmount;
        reserve_y += tokenYAmount;
        
        // LP token 발급
        if(totalSupply() == 0){
            token_liquidity_L = sqrt(reserve_x * reserve_y);
        }
        uint token_amount = sqrt((tokenXAmount * tokenYAmount));
        require(token_amount > minimumLPTokenAmount, "token_amount > minimumLPTokenAmount");
        _mint(msg.sender, token_amount);
        return token_amount;
    }
    function mint(address to) external returns(uint liquidity) {

    }
    function removeLiquidity(uint256 LPTokenAmount, uint256 minimumTokenXAmount, uint256 minimumTokenYAmount) external returns(uint rx, uint ry){
        require(balanceOf(msg.sender) >= LPTokenAmount, "balanceOf(msg.sender) >= LPTokenAmount");
        
        // 소수점 이슈 발생
        //uint stake = LPTokenAmount / totalSupply();
        rx = reserve_x * LPTokenAmount / totalSupply();
        ry = reserve_y * LPTokenAmount / totalSupply();
        console.log("!!!!%d, %d, %d", LPTokenAmount, rx, ry);

        reserve_x -= rx;
        reserve_y -= ry;
        _burn(msg.sender, LPTokenAmount);

        ERC20(token_x).transfer(msg.sender, rx);
        ERC20(token_y).transfer(msg.sender, ry);
    }
    function transfer(address to, uint256 lpAmount) override public returns (bool) { 

    }
    function swap(uint256 tokenXAmount, uint256 tokenYAmount, uint256 tokenMinimumOutputAmount) external returns (uint256 outputAmount){

    }
}