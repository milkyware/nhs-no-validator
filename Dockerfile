ARG CONFIGURATION=Release

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443
LABEL org.opencontainers.image.source="https://github.com/milkyware/nhs-no-validator"
LABEL org.opencontainers.image.title="NHS No Validator API"
LABEL org.opencontainers.image.documentation="https://github.com/milkyware/nhs-no-validator/blob/main/README.md"

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS restore
ARG CONFIGURATION TARGETARCH
WORKDIR /work
COPY *.sln .
COPY ./src/MilkyWare.NhsNoValidator/*.csproj ./src/MilkyWare.NhsNoValidator/
COPY ./src/MilkyWare.NhsNoValidator.Core/*.csproj ./src/MilkyWare.NhsNoValidator.Core/
COPY ./tests/MilkyWare.NhsNoValidator.Core.Tests/*.csproj ./tests/MilkyWare.NhsNoValidator.Core.Tests/
RUN dotnet restore

FROM restore AS test
ARG CONFIGURATION TARGETARCH
COPY . .
RUN dotnet test -c $CONFIGURATION

FROM restore AS publish
ARG CONFIGURATION TARGETARCH
COPY ./src/ ./src/
RUN dotnet publish ./src/MilkyWare.NhsNoValidator -a $TARGETARCH -c $CONFIGURATION -o /app/publish

FROM base AS scan
COPY --from=publish /app/publish .
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
RUN trivy fs --exit-code 1 --severity CRITICAL,HIGH --no-progress /
RUN rm -rf /usr/local/bin/trivy

FROM base AS final
WORKDIR /app
COPY --from=scan /app .
ENTRYPOINT ["dotnet", "MilkyWare.NhsNoValidator.dll"]