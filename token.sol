pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";
contract Token is ERC1155, Ownable {
	address private founder;
	/* config mint auth check   */
	mapping (address => uint8) public _auth;
	function auth(address addr,uint8 state) public  onlyOwner{	_auth[addr]=state;}
	/* config mint  1 open    0 close */
	function authState(address addr) public view returns (bool ) {if(_auth[addr]==1){return true;}else{return false;}} 
	/* config  mint */
	uint32  private _num=50;
	function limitSet(uint32 num) public  onlyOwner{
		require(num>0, "num error");
		require(num<1000000, "Quantity limit exceeded");
		_num=num;
	}
	/* config mint */
	uint256  private totalSupply=500000000000;
	function limitTotalSupply(uint256 num) public  onlyOwner{
		require(num>0, "totalSupply num error");
		totalSupply=num;
	}
    /* 是否开启铸造*/
	bool public isMintActive=true;
	function setisMintActive() public onlyOwner { isMintActive = !isMintActive;}
    function delNftMap(uint256 ID_) public onlyOwner { 
        require(nftMap[ID_].id> 0, "nft id invalid");
        delete nftMap[ID_];
    }

	string private nftURL="";
    function setNftURL(string memory str) public  onlyOwner{
		nftURL=str;
	}
   

    function nftUrl(uint ID_) public view returns (string memory) {
        require(nftMap[ID_].id != 0, "nft not exist");
        string memory str=strConcat(nftURL,Strings.toString(ID_)) ;
        return str;
    }


    function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
            bytes memory _ba = bytes(_a);
            bytes memory _bb = bytes(_b);
            string memory ret = new string(_ba.length + _bb.length);
            bytes memory bret = bytes(ret);
            uint k = 0;
            for (uint i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
            for (uint i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
            return string(ret);
    } 


	mapping(uint256 =>NftObj) public nftMap;
	struct NftObj {
		    uint    id;
		    string  name;  /* 歌名 */
		    string  author;/* 作者 */
			uint256 totalSupply;/* 发行量 */
            address  authorAddr;
	}
	
	function newNftObj(uint ID_, string memory name_,string memory author_, uint256 totalSupply_,address addr_) private {
	    require(ID_ > 0, "nft id invalid");
		if(nftMap[ID_].id == 0){
					nftMap[ID_] = NftObj({
						id: ID_,
						name: name_,
						author: author_,
						totalSupply: totalSupply_,
                        authorAddr:addr_
					});
		}else{
			nftMap[ID_].totalSupply=nftMap[ID_].totalSupply+nftMap[ID_].totalSupply;
		}
	}
	/* mint */
	function mint(address to_, uint ID_, uint num_,string memory name_,string memory author_) public onlyAuth  returns (bool) {
		require(isMintActive, "Mint is not active");
		require(num_<= _num, "Quantity limit exceeded ");//需测试上限限制是否有效
		_mint(to_, ID_, num_, "");
		totalSupply =totalSupply+num_;//更新总数需是否累加 测试
		newNftObj( ID_,name_,author_,  num_,to_);
		return true;
	}

	function mintBatch(address to_, uint[] memory nftIDs_, uint256[] memory nums_) public onlyAuth  returns (bool) {
		require(isMintActive, "Mint is not active");
		uint256 lenlistItem=0;
		for (uint i = 0; i < nftIDs_.length; i++) {
			require(nftIDs_[i] != 0, "nft id err");
		}
		for (uint j = 0; j < nums_.length; j++) {
			require(nums_[j]<= _num, "Quantity limit exceeded ");//需测试上限限制是否有效
			lenlistItem=lenlistItem+nums_[j];
		}
		_mintBatch(to_, nftIDs_, nums_, "");
		totalSupply =totalSupply+lenlistItem;//更新总数需是否累加 测试
		
		for (uint i = 0; i < nftIDs_.length; i++) {
			require(nftIDs_[i] != 0, "nft id err");
		}
		return true;
	}
	
	function burn(address from_, uint boxID_, uint256 num_) public  {
	    require(_msgSender() == from_ || isApprovedForAll(from_, _msgSender()), "burn caller is not owner nor approved");
	    _burn(from_, boxID_, num_);
	}
	
	function burnBatch(address from_, uint[] memory boxIDs_, uint256[] memory nums_) public {
	    require(_msgSender() == from_ || isApprovedForAll(from_, _msgSender()), "burn caller is not owner nor approved");
	    _burnBatch(from_, boxIDs_, nums_);
	}
	
    constructor() public ERC1155("https://game.example/api/item/{id}.json") {
		 founder = msg.sender;
    }
	
	function setURI(string memory URI) public onlyOwner {
           _setURI(URI);
    }
	
	modifier onlyAuth(){
		require(_auth[msg.sender]==1, "must be auth");
	    _;
	}
	
	function getAuth(address addr) public view returns (uint8) {
	    return _auth[addr];
	}


	/*create user*/
	modifier onlyFounder(){
		require(msg.sender==founder, "must be auth");
	    _;
	}
	function getFounder() public view returns (address) {
	    return founder;
	}
	

}

