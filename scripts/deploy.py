import click
from ape import project, accounts


def main():
    sender = accounts.test_accounts[-1]
    nft = project.erc721.deploy(
        "On-Chain Real Estate", "OCRE", "", "on-chain-real-estate", "0.0.1", sender=sender
    )
    click.echo(nft)
