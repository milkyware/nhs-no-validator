FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine as base
WORKDIR /app
EXPOSE 80
EXPOSE 443
LABEL org.opencontainers.image.source="https://github.com/milkyware/nhs-no-validator"
LABEL org.opencontainers.image.title="NHS No Validator API"
LABEL org.opencontainers.image.documentation="https://github.com/milkyware/nhs-no-validator/blob/main/README.md"
VOLUME /logs

FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim-amd64 AS build
WORKDIR /sln
COPY *.sln .
COPY ./src/MilkyWare.NhsNoValidator/*.csproj /sln/src/MilkyWare.NhsNoValidator/
COPY ./src/MilkyWare.NhsNoValidator.Core/*.csproj /sln/src/MilkyWare.NhsNoValidator.Core/
COPY ./tests/MilkyWare.NhsNoValidator.Core.Tests/*.csproj /sln/tests/MilkyWare.NhsNoValidator.Core.Tests/
RUN dotnet restore

FROM build as test
COPY . .
RUN dotnet test -c Debug

FROM build AS publish
COPY ./src/ ./src/
RUN dotnet publish -c Release -o /app/publish

FROM build AS vulnscan
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
RUN trivy filesystem --exit-code 1 --no-progress

FROM base as final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MilkyWare.NhsNoValidator.dll"]