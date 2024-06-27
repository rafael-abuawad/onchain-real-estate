# pragma version ~=0.4.0
"""
@title Simple onchain real estate manager
@custom:contract-name: real_estate
@license MIT
@author rabuawad
"""

# @dev Import and initialize the `ownable` module.
from auth import ownable
initializes: ownable


# @dev Import the `IERC721` custom interface
# generated from the Snekmate library
# implementation.
import tokens.interfaces.IERC721 as IERC721


# @dev Mapping from token ID to agent address.
_agents: HashMap[uint256, address]


# @dev Stores the address of the real estate NFT.
_NFT: immutable(IERC721)


# @dev Fee to mint properties as NFTs (in wei).
_FEE: constant(uint256) = 0.0005e18


@deploy
@payable
def __init__(nft_address: address):
    """
    @param nft_address The address of the deployed NFT
           nft collection that is going to be used to track
           the onchain real estate.
    """
    _NFT = IERC721(nft_address)

    ownable.__init__()


@external
@payable
def mint_property(owner: address, uri: String[432]) -> bool:
    """
    @dev Safely mints a real estate token and transfers
         it to the owner.
    @notice Only by paying a fee can users mint real estate.
    @param owner The 20-byte owner address.
    @param uri The maximum 432-character user-readable
           string URI for computing tokenURI.
    @return True if the minting is successful.
    """
    assert msg.value == _FEE, "Real Estate: incorrect minting fee"
    _NFT.safe_mint(owner, uri)
    return True