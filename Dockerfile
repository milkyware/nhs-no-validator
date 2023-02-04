﻿FROM mcr.microsoft.com/dotnet/aspnet:6.0-alpine as base
WORKDIR /app
EXPOSE 80
EXPOSE 443
LABEL org.opencontainers.image.source="https://github.com/milkyware/nhs-no-validator"
LABEL org.opencontainers.image.title="NHS No Validator API"
LABEL org.opencontainers.image.documentation="https://github.com/milkyware/nhs-no-validator/blob/main/README.md"

FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim-amd64 AS restore
WORKDIR /sln
COPY *.sln .
COPY ./src/MilkyWare.NhsNoValidator/*.csproj ./src/MilkyWare.NhsNoValidator/
COPY ./src/MilkyWare.NhsNoValidator.Core/*.csproj ./src/MilkyWare.NhsNoValidator.Core/
COPY ./tests/MilkyWare.NhsNoValidator.Core.Tests/*.csproj ./tests/MilkyWare.NhsNoValidator.Core.Tests/
RUN dotnet restore

FROM restore as test
COPY . .
RUN dotnet test -c Debug

FROM restore AS publish
COPY ./src/ ./src/
RUN dotnet publish ./src/MilkyWare.NhsNoValidator -c Release -o /app/publish

FROM publish AS vulnscan
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy

FROM base as final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy
RUN trivy filesystem --exit-code 1 --no-progress /
RUN rm /usr/local/bin/trivy
ENTRYPOINT ["dotnet", "MilkyWare.NhsNoValidator.dll"]