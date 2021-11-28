// SPDX-License-Identifier: UNLICENCED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";
import "./libraries/Base64.sol";


contract MyEpicGame is ERC721 {

  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
  }


  // TikenId is the NFTs unique identifier
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  // Array to hold the default data for the characters
  CharacterAttributes[] defaultCharacters;

  // Mapping from the nft's tokenId => NFTs attributes
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
  mapping(address => uint256) public nftHolders;

  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
  event AttackComplete(uint newBossHp, uint newPlayerHp);

  struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint attackDamage;
}

        BigBoss public bigBoss;
    // Data passed to the contract when we first initialize characters
    constructor(
        //console.log("I am a game contract wuahaha");
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterHp,
        uint[] memory characterAttackDmg,
        // boss
        string memory bossName,
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage
    )
    
    ERC721("Heroes", "HERO") {

    bigBoss = BigBoss({
        name: bossName,
        imageURI: bossImageURI,
        hp: bossHp,
        maxHp: bossHp,
        attackDamage: bossAttackDamage
    });

    console.log("Finished initializing boss %s with HP %s, img %s", bigBoss.name, bigBoss.hp, bigBoss.imageURI);

    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];

      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }
    _tokenIds.increment();
  }

  function attackBoss() public {
    uint nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);
  
    require (player.hp > 0, "Error: character must have HP to attack boss");

    require (bigBoss.hp > 0, "Error: boss must have HP to attack");
  
    // Player attacks boss
    if (bigBoss.hp < player.attackDamage) {
        bigBoss.hp = 0;
    } else {
        bigBoss.hp = bigBoss.hp - player.attackDamage;
    }

    // Boss attacks player
    if (player.hp < bigBoss.attackDamage) {
        player.hp = 0;
    } else {
        player.hp = player.hp - bigBoss.attackDamage;
    }

    console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
    console.log("Boss attacked player. New player hp: %s\n", player.hp);

    emit AttackComplete(bigBoss.hp, player.hp);
  }

    // Allows users to pick and get their NFT
    function mintCharacterNFT(uint _characterIndex) external {
        // Current id starts at 1 since incremented in the constructor
        uint256 newItemId = _tokenIds.current();

        // Assign token id to the caller's wallet address
        _safeMint(msg.sender, newItemId);

        // Map tokenId => their character attributes
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            hp: defaultCharacters[_characterIndex].hp,
            maxHp: defaultCharacters[_characterIndex].maxHp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage
        });

        console.log("Minted NFT with tokenID %s and characterIndex %s", newItemId, _characterIndex);

        

        // See who owns what NFT
        nftHolders[msg.sender] = newItemId;

        // Increment tokenId for the next person that uses it
        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }   

  // Displays characters for new players
  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
      return defaultCharacters;
  }
  // Awaken the beast! (retrieve the boss)
  function getBigBoss() public view returns (BigBoss memory) {
      return bigBoss;
  }

  // Checks if player already has a token
  function checkIfUserHasNft() public view returns (CharacterAttributes memory) {
      // Get the tokenId of user's NFT
      uint256 userNftTokenId = nftHolders[msg.sender];
      // If user has an Nft, return the character
      if (userNftTokenId > 0) {
          return nftHolderAttributes[userNftTokenId];
      }
      else {
          CharacterAttributes memory emptyStruct;
          return emptyStruct;
      }
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
  CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

  string memory strHp = Strings.toString(charAttributes.hp);
  string memory strMaxHp = Strings.toString(charAttributes.maxHp);
  string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

  string memory json = Base64.encode(
    bytes(
      string(
        abi.encodePacked(
          '{"name": "',
          charAttributes.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "This is an NFT that lets people play in the game Mataverse Ergo Proxy!", "image": "',
          charAttributes.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value": ',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
          strAttackDamage,'} ]}'
        )
      )
    )
  );

  string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
  );
  
  return output;
  }
}