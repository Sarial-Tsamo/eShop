FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Install .NET 10.0 SDK
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=$PATH:/usr/share/dotnet

# Copy central package versions
COPY Directory.Packages.props ./

# Copy Catalog.API project
COPY src/Catalog.API/Catalog.API.csproj ./src/Catalog.API/

# Restore dependencies
RUN dotnet restore ./src/Catalog.API/Catalog.API.csproj

# Copy everything
COPY . .

# Publish Catalog.API
RUN dotnet publish ./src/Catalog.API/Catalog.API.csproj \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Install .NET 10.0 runtime
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh && \
    chmod +x dotnet-install.sh && \
    ./dotnet-install.sh --channel 10.0 --runtime aspnetcore --install-dir /usr/share/dotnet && \
    rm dotnet-install.sh

# Set DOTNET_ROOT
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH=$PATH:/usr/share/dotnet

COPY --from=build /app/publish .
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80
ENV ASPNETCORE_ENVIRONMENT=Production

RUN apt-get update && apt-get install -y libgssapi-krb5-2

ENTRYPOINT ["dotnet", "Catalog.API.dll"]

