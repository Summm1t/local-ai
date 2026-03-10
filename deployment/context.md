I want to run LLMs like devstral-small-2, qwen3.5:27b and codellama:34b on OVHCloud. Therefore, I
wish to use the docker-compose that is in this project.
Can you make me the needed terraform files under deployment/ovhcloud directory, and take the
folowing into account:

1. Provision the needed resources, and size them so that they can run one LLM at a time with 30B,
   and a quite big context.
2. Make the Terraform scripts modular, and use best practices. Try to make this unbound to OVHCloud,
   so that in the future other cloud providers can be added (AWS, Azure, Google Cloud, ...)
3. Make this application secure, so that only the needed ports are opened to the outer world.

Create tests for the Terraform scripts

Create a bash script under deployment/ovhcloud/scripts which creates random passwords, and replaces
the passwords in .env.example file, after copying this file as ".env"

