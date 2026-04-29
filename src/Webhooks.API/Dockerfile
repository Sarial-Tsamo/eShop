FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

# Set NuGet timeout to 5 minutes
ENV NUGET_TIMEOUT=300

# Copy central package versions
# Copy solution files and central package versions
COPY Directory.Packages.props .
COPY Directory.Build.props .
COPY Directory.Build.targets .
COPY global.json .
COPY nuget.config .


# Copy Webhooks.API project
COPY src/Webhooks.API/Webhooks.API.csproj ./src/Webhooks.API/

# Restore dependencies
RUN for i in {1..3}; do dotnet restore ./src/Webhooks.API/Webhooks.API.csproj --disable-parallel && break || sleep 30; done

# Copy everything
COPY . .

# Publish Webhooks.API
RUN dotnet publish ./src/Webhooks.API/Webhooks.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=/usr/share/dotnet:$PATH

COPY --from=build /app/publish .
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

RUN apt-get update && apt-get install -y libgssapi-krb5-2

ENTRYPOINT ["dotnet", "Webhooks.API.dll"]