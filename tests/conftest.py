import pytest


@pytest.fixture(scope="module")
def sender(accounts):
    return accounts[0]


@pytest.fixture(scope="module")
def on_chain_real_estate(project, sender):
    return project.OnChainRealEstate.deploy(sender, sender=sender)


@pytest.fixture(scope="module")
def manager(project, sender, on_chain_real_estate):
    fee = int(0.0005e18)
    addr = project.Manager.deploy(sender, on_chain_real_estate, fee, sender=sender)
    on_chain_real_estate.transferOwnership(addr, sender=sender)
    return addr
