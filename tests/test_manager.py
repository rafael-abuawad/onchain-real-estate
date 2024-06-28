import ape
from typing import List

FEE = int(0.0005e18)


def list_split(list: List) -> tuple[List, List]:
    mid = len(list) // 2
    return list[mid:], list[:mid]


def address(addr) -> str:
    addr = str(addr)
    size = len(addr)
    return f"{addr[:3]}...{addr[size-3:]}"


def test_manager_has_ownership_of_collection(on_chain_real_estate, manager):
    assert on_chain_real_estate.owner() == manager


def test_manager_nft_collection(on_chain_real_estate, manager):
    assert manager.onChainRealEstateCollection() == on_chain_real_estate


def test_manager_fee(manager):
    assert manager.fee() == FEE


def test_manager_fee(manager):
    assert manager.agentFee() == FEE


def test_manager_cannot_register_agent_with_incorrect_fee(manager, accounts):
    incorrect_fee = FEE - 1
    for account in accounts:
        with ape.reverts():
            manager.registerAgent(account, sender=account, value=incorrect_fee)


def test_manager_can_register_agent_with_correct_fee(manager, accounts):
    for account in accounts:
        manager.registerAgent(account, sender=account, value=FEE)


def test_manager_cannot_register_the_same_agent_twice(manager, accounts):
    for account in accounts:
        manager.registerAgent(account, sender=account, value=FEE)

    for account in accounts:
        with ape.reverts():
            manager.registerAgent(account, sender=account, value=FEE)


def test_manager_register_nft(manager, accounts):
    for agent in accounts:
        manager.registerAgent(agent, sender=agent, value=FEE)

    uri = ""
    for agent in accounts:
        manager.register(agent, uri, sender=agent, value=FEE)


def test_manager_non_agents_cannot_mint(manager, accounts):
    agents, non_agents = list_split(accounts)
    for agent in agents:
        manager.registerAgent(agent, sender=agent, value=FEE)

    uri = ""
    for agent in non_agents:
        with ape.reverts():
            manager.register(agent, uri, sender=agent, value=FEE)


def test_manager_registration_reverts_if_icorrect_fee_is_paid(manager, accounts):
    for agent in accounts:
        manager.registerAgent(agent, sender=agent, value=FEE)

    uri = ""
    incorrect_fee = FEE - 1
    for agent in accounts:
        with ape.reverts():
            manager.register(agent, uri, sender=agent, value=incorrect_fee)


def test_manger_agent_mints_nfts(manager, accounts, on_chain_real_estate):
    for agent in accounts:
        manager.registerAgent(agent, sender=agent, value=FEE)

    uri = ""
    mints = 3
    for agent in accounts:
        for _ in range(mints):
            manager.register(agent, uri, sender=agent, value=FEE)

    for agent in accounts:
        assert on_chain_real_estate.balanceOf(agent) == mints

    assert on_chain_real_estate.totalSupply() == mints * len(accounts)


def test_manager_token_uris(manager, accounts, on_chain_real_estate):
    for agent in accounts:
        manager.registerAgent(agent, sender=agent, value=FEE)

    uri = ""
    mints = 3
    for agent in accounts:
        for _ in range(mints):
            manager.register(agent, uri, sender=agent, value=FEE)

    for agent in accounts:
        for index in range(on_chain_real_estate.balanceOf(agent)):
            id = on_chain_real_estate.tokenOfOwnerByIndex(agent, index)
            print(f"Owner: {address(agent)} at {index} => {id}")
            assert on_chain_real_estate.tokenURI(id) == uri
