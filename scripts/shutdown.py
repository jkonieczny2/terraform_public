#!/usr/bin/env python
import sys
import boto3
import logging
import argparse

from authenticate import get_boto3_creds_for_environment, get_ec2_client, SECRETS, REGIONS

LOGGER = logging.getLogger("AWSShutdownScript")

def control_instances_in_region(region, environment, start=False, dry_run=False, force=False, include_terminated=False):
    """
    Start or stop all instances in region

    Args:

    region           : AWS region
    environment      : environment (i.e. account) to stop instances in

    Kwargs:

    start               : if True, starts instances instead of stopping (default=False)
    dry_run             : if True, just prints instances that wouldbe stopped (default=False)
    force               : if True, force-stop instances (default=False)
    include_terminated  : if True, also try to start/stop terminated instances (default=False)
    """
    cli = get_ec2_client(
        region,
        environment,
    )

    resp = cli.describe_instances()

    instances = []
    for res in resp["Reservations"]:
        for instance in res["Instances"]:
            iid = instance["InstanceId"]
            state = instance["State"]["Name"]

            if start and state=="running":
                LOGGER.debug(f"Not going to start instance {iid} because it's already running")
                continue

            if not start and state != "running":
                LOGGER.debug(f"Not going to stop instance {iid} because it is not running")
                continue

            if not include_terminated and state == "terminated":
                LOGGER.debug(f"Doing nothing with instance {iid} because it is terminated")
                continue

            instances.append(iid)

    for iid in instances:
        msg = "Shutting down" if not start else "Starting"
        LOGGER.info(f"{msg} instance {iid} in region {region} (dry_run={dry_run})")

    if dry_run:
        return

    if not start:
        cli.stop_instances(
            InstanceIds=instances,
            Force=force,
        )
    else:
        cli.start_instances(
            InstanceIds=instances,
        )

def setup_logging(args):
    lvl = logging.INFO if not args.verbose else logging.DEBUG
    fmt = "%(asctime)s %(levelname)s %(name)s - %(message)s"

    handlers = [logging.StreamHandler()]

    logging.basicConfig(
        level=lvl,
        format=fmt,
        handlers=handlers,
    )

def create_parser():
    p = argparse.ArgumentParser()

    p.add_argument("--regions", "-R", nargs="+", default=REGIONS, help="Regions to shut down instances in")
    p.add_argument("--start", "-S", action="store_true", help="Start instances instead of stopping them")
    p.add_argument("--environment", "-E", choices=SECRETS.keys(), help="Environment to control instances in", default="prod")
    p.add_argument("--force", "-F", action="store_true", help="Force-stop instances")
    p.add_argument("--include-terminated", "-T", action="store_true", help="Attempt to control terminated instances")

    p.add_argument("--dry-run", "-n", action="store_true")
    p.add_argument("--verbose", "-v", action="store_true")

    return p

def main():
    p = create_parser()
    args = p.parse_args()

    setup_logging(args)

    for region in args.regions:
        control_instances_in_region(
            region,
            args.environment,
            start=args.start,
            force=args.force,
            dry_run=args.dry_run,
            include_terminated=args.include_terminated,
        )

    return 0

if __name__ == "__main__":
    sys.exit(main())
