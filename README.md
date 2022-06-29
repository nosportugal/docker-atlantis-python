# Atlantis with Python

Original Base Image of Atlantis that uses Python Libraries.

## About the Project

Upon using lambda functions in a repository, using the base image of Atlantis would run into errors since these functions use python. Therefore, this project was designed to get the latest image from Atlantis and adding python to the image in order to run these specific cases.

## Built With

This project uses:

- [Atlantis](https://github.com/runatlantis/atlantis)
- [Github Packages](https://github.com/features/packages)

## Getting Started

We suggest you create a specific repository where you can edit your terraform files and call the module from this [repository](https://github.com/terraform-aws-modules/terraform-aws-atlantis).

One of the arguments is `atlantis_image` and this is where we can specify the image from our packages. While Base Atlantis doesn't update a minor version (p.e from v0.19 to v0.20), you will have no need to update the image since this project will be in charge of the updates for the patches and the latest image will always point to the latest stable version.

   ```bash

   module "atlantis" {
    source = "git@github.com:nosportugal/terraform-aws-atlantis?ref=github-app-support"

    name = "atlantis"

    atlantis_image = "ghcr.io/nosportugal/docker-atlantis-python:0.19"

   }
   ```

As an alternative, you can always choose to create your own Dockerfile and point to the image.

```bash
FROM ghcr.io/nosportugal/docker-atlantis-python:0.19
```

You can check the packages [here](https://github.com/nosportugal/docker-atlantis-python/pkgs/container/docker-atlantis-python).

## Contributing

Contributions are what make the open source community awesome! Any contributions you make are **greatly appreciated**.

1. Fork the Project

2. Create your Feature Branch

   ```bash
   git checkout -b feature/my-feature
   ```

3. Commit your Changes

   ```bash
   git commit -m 'Add some feature'
   ```

4. Push to the Branch

   ```bash
   git push origin feature/my-feature
   ```

5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.
