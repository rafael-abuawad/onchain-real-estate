import ape


def test_collection_name(on_chain_real_estate):
    assert on_chain_real_estate.name() == "On-Chain Real Estate"


def test_collection_symbol(on_chain_real_estate):
    assert on_chain_real_estate.symbol() == "OCRE"


def test_collection_owner(on_chain_real_estate, sender):
    assert on_chain_real_estate.owner() == sender


def test_token_uri(on_chain_real_estate, accounts):
    for id in range(len(accounts)):
        with ape.reverts():
            on_chain_real_estate.tokenURI(id)


def test_mint_multiple_nfts(on_chain_real_estate, sender, accounts):
    mints = 3
    uri = ""
    for account in accounts:
        for _ in range(mints):
            on_chain_real_estate.safeMint(account, uri, sender=sender)
    for account in accounts:
        on_chain_real_estate.balanceOf(account) == mints
